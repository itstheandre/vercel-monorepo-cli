console.log("Changes made");
const fs = require("fs-extra");
const { promisify } = require("util");
const cp = require("child_process");
const exec = promisify(cp.exec);

async function copy() {
  const buffer = await fs.readFile("./dist/index.js");
  const content = buffer.toString();

  const theScript = `#! /usr/local/bin/node
  
  ${content}
  `.replace('"use strict";', "");

  //   return;
  console.log("Deleting file");
  await exec("rimraf ./single.sh");
  setTimeout(async () => {
    console.log("deleted, and now: recreating");
    await fs.writeFile("single.sh", theScript);
    setTimeout(async () => {
      await fs.chmod("single.sh", "755");
    }, 2000);
  }, 2000);
}

copy().catch(console.error);
