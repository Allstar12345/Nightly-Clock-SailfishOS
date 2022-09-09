.pragma library
// needs this import to fix for SailfishOS along wth   db = Sql.LocalStorage.
.import QtQuick.LocalStorage 2.0 as Sql


var db;
var searchcriteria = "";
var loadLimit = "";


// opens database at launch
function openDB()
{
    db =  Sql.LocalStorage.openDatabaseSync("nightlyalarmfavs","1.0","alarmtimes Database",10000000);
    createTable();
}


// creates table if it doesn't exist, otherwise ignores
function createTable()
{
    db.transaction(
       function(tx) {
          tx.executeSql("CREATE TABLE IF NOT EXISTS favs (id INTEGER PRIMARY KEY AUTOINCREMENT, time TEXT, timeformat TEXT, modified DATETIME)");
       }
    )
}

// deletes table
function dropTable()
{
    db.transaction(
       function(tx) {
          tx.executeSql("DROP TABLE IF EXISTS favs");
       }
    )
}


// updates a single history record
function updateFavourite(favoriteItem)
{
    db.transaction(
       function(tx) {
          tx.executeSql("UPDATE favs SET time = ?, timeformat = ?,  modified = ? WHERE id = ?",
                        [favoriteItem.time, favoriteItem.timeformat, favoriteItem.modified, favoriteItem.id]);
       }
    )
}

// deletes a single history record
function deleteFavorite(id)
{
    db.transaction(
       function(tx) {
          tx.executeSql("DELETE FROM favs WHERE id = ?", [id]);
       }
    )
}
function search(model)
{
    model.clear();
    if (searchcriteria === "") {
        model.clear();
        var sqlstringer = "SELECT id, time, timeformat FROM favs";
        db.readTransaction(
           function(tx) {
              var rs;
              rs = tx.executeSql(sqlstringer);
                 for (var i = 0; i < rs.rows.length; i++) {
                    model.append(rs.rows.item(i))
                 }
           }
        )
    }

    else {
        model.clear();
        var sqlstring = "SELECT id, time, timeformat FROM favs";
        sqlstring += " WHERE timeformat LIKE '%" + searchcriteria + "%' OR time LIKE '%" + searchcriteria + "%'"
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
}


// creates a single history record
function createFavorite(favoriteItem)
{
    db.transaction(
       function(tx) {
          tx.executeSql("INSERT INTO favs (time, timeformat,  modified) VALUES(?,?,?)",[favoriteItem.time, favoriteItem.timeformat, favoriteItem.modified]);
          console.debug("Favorite Item Created");
       }
    )
}

// updates a single history record
function updateFavourite(favoriteItem)
{
    db.transaction(
       function(tx) {
          tx.executeSql("UPDATE favs SET time = ?, timeformat = ?,  modified = ? WHERE id = ?",
                        [favoriteItem.time, favoriteItem.timeformat, favoriteItem.modified, favoriteItem.id]);
       }
    )
}

// deletes a single history record
function deleteFavorite(id)
{
    db.transaction(
       function(tx) {
          tx.executeSql("DELETE FROM favs WHERE id = ?", [id]);
       }
    )
}

function readFavoriteList(model)
{
    model.clear();
    var sqlstring = "SELECT id, time, timeformat FROM favs";

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
          var rs = tx.executeSql("SELECT * FROM favs WHERE id=?", [id])
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
    var sqlstring = "SELECT id, time, timeformat FROM favs ORDER BY id DESC LIMIT "  + loadLimit;
   // for future when I nodoubtly forget what this does
    // order row by id in descending order & limit to 4 loaded
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
    return {time: "", timeformat: "", modified: new Date()}
}





