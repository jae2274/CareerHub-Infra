/* global use, db */
// MongoDB Playground
// Use Ctrl+Space inside a snippet or a string literal to trigger completions.

const database = "finded-history";
const collections = [
  {
    name: "company",
    indexes: [
      {
        name: "site_1_companyId_1",
        index: {
          site: 1,
          companyId: 1,
        },
        options: {
          unique: true,
        },
      },
    ],
  },
  {
    name: "JobPosting",
    indexes: [
      {
        name: "site_1_postingId_1",
        index: {
          site: 1,
          postingId: 1,
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
