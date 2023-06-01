import { defineConfig } from "vite";
import adapter from "elm-pages/adapter/netlify.js";
import { config } from 'dotenv';
config();

export default {
  vite: defineConfig({}),
  adapter,
  headTagsTemplate(context) {
    return `
<link rel="stylesheet" href="/style.css" />
<meta name="generator" content="elm-pages v${context.cliVersion}" />
`;
  },
  preloadTagForFile(file) {
    // add preload directives for JS assets and font assets, etc., skip for CSS files
    // this function will be called with each file that is procesed by Vite, including any files in your headTagsTemplate in your config
    return !file.endsWith(".css");
  },
};
