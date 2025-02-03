/* global use, db */
// MongoDB Playground
// Use Ctrl+Space inside a snippet or a string literal to trigger completions.

const database = "userinfo";
const collections = [
  {
    name: "matchJob",
    indexes: [
      {
        name: "userId_1",
        index: {
          userId: 1,
        },
        options: {
          unique: true,
        },
      },
    ],
  },
  {
    name: "scrapJob",
    indexes: [
      {
        name: "userId_1_site_1_postingId_1",
        index: {
          userId: 1,
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
  // db.createCollection(collection.name);

  for (const index of collection.indexes) {
    db[collection.name].createIndex(index.index, index.options);
  }
}
