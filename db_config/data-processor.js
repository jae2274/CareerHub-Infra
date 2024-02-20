/* global use, db */
// MongoDB Playground
// Use Ctrl+Space inside a snippet or a string literal to trigger completions.

const database = "data-processor";
const collections = [
  {
    name: "jobPostingInfo",
    indexes: [
      {
        name: "jobPostingId.site_1_jobPostingId.postingId_1",
        index: {
          "jobPostingId.site": 1,
          "jobPostingId.postingId": 1,
        },
        options: {
          unique: true,
        },
      },
    ],
  },
  {
    name: "skill",
    indexes: [
      {
        name: "defaultName_1",
        index: {
          defaultName: 1,
        },
        options: {
          unique: true,
        },
      },
      {
        name: "skillNames.name_1",
        index: {
          "skillNames.name": 1,
        },
        options: {
          unique: true,
        },
      },
    ],
  },
  {
    name: "company",
    indexes: [
      {
        name: "siteCompanies.site_1_siteCompanies.companyId_1",
        index: {
          "siteCompanies.site": 1,
          "siteCompanies.companyId": 1,
        },
        options: {
          unique: true,
        },
      },
    ],
  },
];

// Create a new database.
use(database);

for (const collection of collections) {
  db.createCollection(collection.name);

  for (const index of collection.indexes) {
    db[collection.name].createIndex(index.index, index.options);
  }
}

db["jobPostingInfo"].getIndexes();
