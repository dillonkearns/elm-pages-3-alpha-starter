export async function environmentVariable(name) {
  const result = process.env[name];
  if (result) {
    return result;
  } else {
    throw `No environment variable called ${name}\n\n
      Available:\n\n${Object.keys(process.env).slice(0, 5).join("\n")}`;
  }
}
