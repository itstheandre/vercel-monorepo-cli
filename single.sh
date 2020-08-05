#! /usr/local/bin/node
  
  
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const fs_extra_1 = __importDefault(require("fs-extra"));
const child_process_1 = __importDefault(require("child_process"));
const util_1 = require("util");
const chalk_1 = __importStar(require("chalk"));
const exec = util_1.promisify(child_process_1.default.exec);
const currentDir = process.cwd();
// console.log("currentDir:", currentDir);
const [, , name] = process.argv;
const allArgs = process.argv.filter((_, i) => i > 0);
const isAll = !!allArgs.filter((e) => e === "all" || e === "-a" || e === "--all").length;
async function main() {
    // * Getting all Files in directory
    const allFiles = await fs_extra_1.default.readdir(currentDir);
    //   * Check if there is a .vercel folder
    const vercelFiles = allFiles.filter((el) => el.includes(".vercel"));
    // * No Vercel Folder, no script
    if (!vercelFiles.length) {
        return errorHandling.noProject();
    }
    //   * No need to pass a name Flag if there is only one project setup in the folder
    if (vercelFiles.length === 1 && vercelFiles[0] === ".vercel") {
        console.log(chalk_1.default.bgBlack.whiteBright("single projects, lets deploy"));
        return;
    }
    //   * If We pass the all Flag, we deploy all the projects in the folder
    const removeDotFiles = vercelFiles
        .filter((e, i) => i > 0 && e !== ".vercelignore")
        .map((e) => e.split(".vercel")[1]);
    if (isAll) {
        console.log("isAll:", isAll);
        await cleanup(allFiles);
        return deployAll(removeDotFiles);
    }
    const folderName = `.${name}`;
    //   console.log("folderName:", folderName);
    if (!removeDotFiles.includes(folderName)) {
        return errorHandling.noProjectName();
    }
    await cleanup(allFiles);
    return execOne(folderName);
}
main()
    .catch(console.error)
    .finally(() => {
    return console.log("done");
});
async function deployAll(arr) {
    //   console.log("arr:", arr);
    console.log(chalk_1.default.bgWhiteBright.black("YOU ARE ABOUT TO DEPLOY ALL PROJECTS"));
    for (let i = 0; i < arr.length; i++) {
        const folder = arr[i];
        console.log("folder:", folder);
        await execOne(folder);
    }
    return;
}
async function execOne(folder) {
    if (folder) {
        await fs_extra_1.default.copy(`.vercel${folder}`, ".vercel");
    }
    return console.log(`DEPLOYING ${folder}`);
    return execCommand();
}
async function execCommand() {
    console.log("starting deploymenbt");
    const { stderr, stdout } = await exec("vercel --prod");
    console.log("stdout:", stdout);
    console.log("stderr:", stderr);
    return;
}
// * Clears .vercel and now.json files, in case they exist
async function cleanup(allFiles) {
    if (allFiles.includes("now.json")) {
        await removeNow();
    }
    if (allFiles.includes(".vercel")) {
        await removeVercel();
    }
    return true;
}
// * Clears .vercel
async function removeVercel() {
    console.log(chalk_1.default.bgWhite.black("Deleting .vercel Folder"));
    await fs_extra_1.default.remove(".vercel");
}
//  * Clears now.json
async function removeNow() {
    console.log(chalk_1.bgWhite.black("Deleting now.json Folder"));
    await fs_extra_1.default.remove("now.json");
}
// * Error handling functions. Colored console log
const errorHandling = {
    noProject() {
        console.log(chalk_1.default.redBright.bgWhiteBright("There is no vercel project setup in this directory"));
        return;
    },
    noName() {
        console.log(chalk_1.default.red("No name flag was added"));
        return;
    },
    noProjectName() {
        console.log(chalk_1.default.bgGreen.blue("No project setup with that name"));
        return;
    },
};

  