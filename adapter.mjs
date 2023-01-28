import fs from "fs";

export default async function run({
  renderFunctionFilePath,
  routePatterns,
  apiRoutePatterns,
  portsFilePath,
  htmlTemplate,
}) {
  console.log("Running adapter script");
  ensureDirSync("functions/render");
  ensureDirSync("functions/server-render");

  fs.copyFileSync(
    renderFunctionFilePath,
    "./functions/render/elm-pages-cli.js"
  );
  fs.copyFileSync(
    renderFunctionFilePath,
    "./functions/server-render/elm-pages-cli.js"
  );
  fs.copyFileSync(portsFilePath, "./functions/render/custom-backend-task.mjs");
  fs.copyFileSync(
    portsFilePath,
    "./functions/server-render/custom-backend-task.mjs"
  );

  fs.writeFileSync(
    "./functions/render/index.mjs",
    rendererCode(true, htmlTemplate)
  );
  fs.writeFileSync(
    "./functions/server-render/index.mjs",
    rendererCode(false, htmlTemplate)
  );
  // TODO rename functions/render to functions/fallback-render
  // TODO prepend instead of writing file

  const apiServerRoutes = apiRoutePatterns.filter(isServerSide);

  ensureValidRoutePatternsForNetlify(apiServerRoutes);

  const apiRouteRedirects = apiServerRoutes
    .map((apiRoute) => {
      if (apiRoute.kind === "prerender-with-fallback") {
        return `${apiPatternToRedirectPattern(
          apiRoute.pathPattern
        )} /.netlify/builders/render 200`;
      } else if (apiRoute.kind === "serverless") {
        return `${apiPatternToRedirectPattern(
          apiRoute.pathPattern
        )} /.netlify/functions/server-render 200`;
      } else {
        throw "Unhandled 2";
      }
    })
    .join("\n");

  const redirectsFile =
    routePatterns
      .filter(isServerSide)
      .map((route) => {
        if (route.kind === "prerender-with-fallback") {
          return `${route.pathPattern} /.netlify/builders/render 200
${route.pathPattern}/content.dat /.netlify/builders/render 200`;
        } else {
          return `${route.pathPattern} /.netlify/functions/server-render 200
${route.pathPattern}/content.dat /.netlify/functions/server-render 200`;
        }
      })
      .join("\n") +
    "\n" +
    apiRouteRedirects +
    "\n";

  fs.writeFileSync("dist/_redirects", redirectsFile);
}

function ensureValidRoutePatternsForNetlify(apiRoutePatterns) {
  const invalidNetlifyRoutes = apiRoutePatterns.filter((apiRoute) =>
    apiRoute.pathPattern.some(({ kind }) => kind === "hybrid")
  );
  if (invalidNetlifyRoutes.length > 0) {
    throw (
      "Invalid Netlify routes!\n" +
      invalidNetlifyRoutes
        .map((value) => JSON.stringify(value, null, 2))
        .join(", ")
    );
  }
}

function isServerSide(route) {
  return (
    route.kind === "prerender-with-fallback" || route.kind === "serverless"
  );
}

/**
 * @param {boolean} isOnDemand
 * @param {string} htmlTemplate
 */
function rendererCode(isOnDemand, htmlTemplate) {
  return `import * as path from "path";
import * as busboy from "busboy";
import { fileURLToPath } from "url";
import * as renderer from "elm-pages/generator/src/render.js";
import * as preRenderHtml from "elm-pages/generator/src/pre-render-html.js";
const htmlTemplate = ${JSON.stringify(htmlTemplate)};

${
  isOnDemand
    ? `import { builder } from "@netlify/functions";

export const handler = builder(render);`
    : `

export const handler = render;`
}


/**
 * @param {import('aws-lambda').APIGatewayProxyEvent} event
 * @param {any} context
 */
async function render(event, context) {
  const requestTime = new Date();
  const compiledPortsFile = "./custom-backend-task.mjs";

  try {
    const basePath = "/";
    const mode = "build";
    const addWatcher = () => {};

    const renderResult = await renderer.render(
      compiledPortsFile,
      basePath,
      (await import("./elm-pages-cli.js")).default,
      mode,
      event.path,
      await reqToJson(event, requestTime),
      addWatcher,
      false
    );

    const statusCode = renderResult.is404 ? 404 : renderResult.statusCode;

    if (renderResult.kind === "bytes") {
      return {
        body: Buffer.from(renderResult.contentDatPayload.buffer).toString("base64"),
        isBase64Encoded: true,
        headers: {
          "Content-Type": "application/octet-stream",
          "x-powered-by": "elm-pages",
          ...renderResult.headers,
        },
        statusCode,
      };
    } else if (renderResult.kind === "api-response") {
      const serverResponse = renderResult.body;
      return {
        body: serverResponse.body,
        multiValueHeaders: serverResponse.headers,
        statusCode: serverResponse.statusCode,
        isBase64Encoded: serverResponse.isBase64Encoded,
      };
    } else {
      return {
        body: preRenderHtml.replaceTemplate(htmlTemplate, renderResult.htmlString),
        headers: {
          "Content-Type": "text/html",
          "x-powered-by": "elm-pages",
          ...renderResult.headers,
        },
        statusCode,
      };
    }
  } catch (error) {
    console.error(error);
    console.error(JSON.stringify(error, null, 2));
    return {
      body: \`<body><h1>Error</h1><pre>\${JSON.stringify(error, null, 2)}</pre></body>\`,
      statusCode: 500,
      headers: {
        "Content-Type": "text/html",
        "x-powered-by": "elm-pages",
      },
    };
  }
}

/**
 * @param {import('aws-lambda').APIGatewayProxyEvent} req
 * @param {Date} requestTime
 * @returns {{method: string; rawUrl: string; body: string?; headers: Record<string, string>; requestTime: number; multiPartFormData: unknown }}
 */
function reqToJson(req, requestTime) {
  return {
    method: req.httpMethod,
    headers: req.headers,
    rawUrl: req.rawUrl,
    body: req.body,
    requestTime: Math.round(requestTime.getTime()),
    multiPartFormData: null,
  };
}
`;
}

/**
 * @param {fs.PathLike} dirpath
 */
function ensureDirSync(dirpath) {
  try {
    fs.mkdirSync(dirpath, { recursive: true });
  } catch (err) {
    if (err.code !== "EEXIST") throw err;
  }
}

/** @typedef {{kind: 'dynamic'} | {kind: 'literal', value: string}} ApiSegment */

/**
 * @param {ApiSegment[]} pathPattern
 */
function apiPatternToRedirectPattern(pathPattern) {
  return (
    "/" +
    pathPattern
      .map((segment, index) => {
        switch (segment.kind) {
          case "literal": {
            return segment.value;
          }
          case "dynamic": {
            return `:dynamic${index}`;
          }
          default: {
            throw "Unhandled segment: " + JSON.stringify(segment);
          }
        }
      })
      .join("/")
  );
}
