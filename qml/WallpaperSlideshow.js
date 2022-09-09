.pragma library
// needs this import to fix for SailfishOS along wth   db = Sql.LocalStorage.
.import QtQuick.LocalStorage 2.0 as Sql


var db;
var searchcriteria = "";
var loadLimit = "";


// opens database at launch
function openDB()
{
    db =  Sql.LocalStorage.openDatabaseSync("nightlywallpaperslideshow","1.0","wallpaperslideshow Database",10000000);
    createTable();
}


// creates table if it doesn't exist, otherwise ignores
function createTable()
{
    db.transaction(
       function(tx) {
          tx.executeSql("CREATE TABLE IF NOT EXISTS wallslide (id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT, modified DATETIME)");
       }
    )
}

// deletes table
function dropTable()
{
    db.transaction(
       function(tx) {
          tx.executeSql("DROP TABLE IF EXISTS wallslide");
       }
    )
}


// updates a single history record
function updateFavourite(favoriteItem)
{
    db.transaction(
       function(tx) {
          tx.executeSql("UPDATE wallslide SET url = ?, modified = ? WHERE id = ?",
                        [favoriteItem.url, favoriteItem.modified, favoriteItem.id]);
       }
    )
}

// deletes a single history record
function deleteFavorite(id)
{
    db.transaction(
       function(tx) {
          tx.executeSql("DELETE FROM wallslide WHERE id = ?", [id]);
       }
    )
}

// creates a single history record
function createFavorite(favoriteItem)
{
    db.transaction(
       function(tx) {
          tx.executeSql("INSERT INTO wallslide (url, modified) VALUES(?,?)",[favoriteItem.url, favoriteItem.modified]);
          console.debug("Favorite Item Created");
       }
    )
}

// updates a single history record
function updateFavourite(favoriteItem)
{
    db.transaction(
       function(tx) {
          tx.executeSql("UPDATE wallslide SET url = ?, modified = ? WHERE id = ?",
                        [favoriteItem.url, favoriteItem.modified, favoriteItem.id]);
       }
    )
}

// deletes a single history record
function deleteFavorite(id)
{
    db.transaction(
       function(tx) {
          tx.executeSql("DELETE FROM wallslide WHERE id = ?", [id]);
       }
    )
}

function readFavoriteList(model)
{
    model.clear();
    var sqlstring = "SELECT id, url FROM wallslide";

    db.readTransaction(
       function(tx) {
          var rs;
          rs = tx.executeSql(sqlstring);
             for (var i = 0; i < rs.rows.length; i++) {
                model.append(rs.rows.item(i))
             }
       }
    )

}

// read a single history item
function readFavoriteItem(id) {
    var data = {}
    db.readTransaction(
       function(tx) {
          var rs = tx.executeSql("SELECT * FROM wallslide WHERE id=?", [id])
          if(rs.rows.length === 1) {
             data = rs.rows.item(0)
          }
       }
    )
    return data;
}
function readFavouritesListLimit(model)
{
    model.clear();
    var sqlstring = "SELECT id, url FROM wallslide ORDER BY id DESC LIMIT "  + loadLimit;
   // for future when I nodoubtly forget what this does
    // order row by id in descending order & limit to pre-set limit from loadLimit string
    db.readTransaction(
       function(tx) {
          var rs;
          rs = tx.executeSql(sqlstring);
             for (var i = 0; i < rs.rows.length; i++) {
                model.append(rs.rows.item(i))
             }
       }
    )

}

// create a default history item
function defaultItem()
{
    return {url: "", modified: new Date()}
}





