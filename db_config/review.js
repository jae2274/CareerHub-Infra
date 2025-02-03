/* global use, db */
// MongoDB Playground
// Use Ctrl+Space inside a snippet or a string literal to trigger completions.

const database = "review";
const collections = [
  {
    name: "review",
    indexes: [
      {
        name: "site_1_companyName_1_summary_1_reviewUserId_1",
        index: {
          site: 1,
          companyName: 1,
          summary: 1,
          reviewUserId: 1,
        },
        options: {
          unique: true,
        },
      },
      {
        name: "site_1_companyName_1_date_1",
        index: {
          site: 1,
          companyName: 1,
          date: -1,
        },
      },
    ],
  },
  {
    name: "company",
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
        name: "otherNames_1",
        index: {
          otherNames: 1,
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
  // db.createCollection(collection.name);

  for (const index of collection.indexes) {
    db[collection.name].createIndex(index.index, index.options);
  }
}
