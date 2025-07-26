// e.g. cd 2.2.1 など親ディレクトリに移動してから実行する
import * as path from "path";

if (process.argv.length === 2) {
 console.error('Expected at least one argument!');
 process.exit(1);
}

const dirname = process.argv[2].replace(/(.+)\/$/, "$1");
// check directory exists
import { existsSync } from 'fs';
if (!existsSync(dirname)) {
 console.error('Directory does not exist!');
 process.exit(1);
}

// extract string with numbers and dots like '2.2.1' from dirname
let renamed = '';
const regex = /\d+(\.\d+)+/g;
const match = dirname.match(regex);
if (!match) {
 console.error('No version number found in directory name!');
 process.exit(1);
} else {
  renamed = match[0];
}

import { readdirSync, readFileSync, writeFileSync, unlinkSync, rmdir } from "fs";
const files = readdirSync(dirname);

// if files are multiple, then rename files with suffix like '*-1.ts', '*-2.ts' etc.
if (files.length > 1) {
  for (const [i, file] of files.entries()) {
    const newFilename = createRenamedFilename(file, renamed, i);

    // Insert a string at the beginning of the file as a comment
    const newFileContent = createNewFileContent(file);

    // create a new file
    createNewFile(newFilename, newFileContent, dirname);

    // remove the old file
    try {
      unlinkSync(`${dirname}/${file}`);
      console.log(`Deleted ${dirname}/${file}`);
    } catch (error) {
      throw error;
    }
  }
  // remove the old directory after all old files are deleted
  rmdir(dirname, (err) => {
    if (err) {
      throw err;
    }
    console.log(`${dirname} is deleted!`);
  });
} else {
  const file = files[0];
  const newFilename = createRenamedFilename(file, renamed, undefined);
  const newFileContent = createNewFileContent(file);

  // create a new file
  createNewFile(newFilename, newFileContent, dirname);

  // remove the old file
  try {
    unlinkSync(`${dirname}/${file}`);
    console.log(`Deleted ${dirname}/${file}`);
  } catch (error) {
    throw error;
  }

  // remove the old directory
  rmdir(dirname, (err) => {
    if (err) {
      throw err;
    }
    console.log(`${dirname} is deleted!`);
  });
}

function createNewFile(newFilename, newFileContent, dirname) {
  const parentDir = path.resolve(dirname, "..");
  writeFileSync(`${parentDir}/${newFilename}`, newFileContent);
  console.log(`Created ${parentDir}/${newFilename}`);
}

function createNewFileContent(file) {
  const oldData = readFileSync(`${dirname}/${file}`).toString();
  const newData = `// ${dirname}

${oldData}
`;
  return newData;
}

function createRenamedFilename(file, renamed, i) {
  const suffix = i === undefined ? '' : `-${i + 1}`;
  const newFile = `${renamed}${suffix}${path.extname(file)}`;

  return newFile;
}
