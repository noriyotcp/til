// 👇️ using import/export syntax
import {readdir} from 'fs/promises';

if (process.argv.length === 2) {
  console.error("Expected at least one argument!");
  process.exit(1);
}

const dirname = process.argv[2].replace(/(.+)\/$/, "$1");
// check directory exists
import { existsSync } from "fs";
if (!existsSync(dirname)) {
  console.error("Directory does not exist!");
  process.exit(1);
}

async function listDirectories(pth) {
  const directories = (await readdir(pth, {withFileTypes: true}))
    .filter(dirent => dirent.isDirectory())
    .map(dir => dir.name);

  return directories;
}

// get pwd
const entrypoint = process.cwd();

const directories = await listDirectories(dirname);
console.log(directories);

// change directory to dirname
process.chdir(dirname);
console.log(`Move to ${process.cwd()}`);

// reorgFiles.jsを実行する
import { execSync } from 'child_process';

for (const dir of directories) {
  console.log(`Reorganizing files in ${dir}`);
  execSync(
    `node ${entrypoint}/reorgFiles.js "${dir}"`
  );
}

// move back to the entrypoint
process.chdir(entrypoint);
console.log(`Back to ${process.cwd()}`);
