.pragma library

// needs this import to fix for SailfishOS along wth   db = Sql.LocalStorage.
.import QtQuick.LocalStorage 2.0 as Sql

var db;
var searchcriteria = "";

// opens database at launch
function openDB()
{
    db = Sql.LocalStorage.openDatabaseSync("nightlyinterhist","1.0","nightlyinterhist",10000000);
    createTable();
}

// creates table if it doesn't exist, otherwise ignores
function createTable()
{
    db.transaction(
       function(tx) {
          tx.executeSql("CREATE TABLE IF NOT EXISTS history (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, url TEXT, modified DATETIME)");
       }
    )
}

// deletes table
function dropTable()
{
    db.transaction(
       function(tx) {
          tx.executeSql("DROP TABLE IF EXISTS history");
       }
    )
}

// creates a single history record
function createhistory(historyItem)
{
    db.transaction(
       function(tx) {
          tx.executeSql("INSERT INTO history (title, url,  modified) VALUES(?,?,?)",[historyItem.title, historyItem.url, historyItem.modified]);
          console.debug("History Item Created");
       }
    )
}

// updates a single history record
function updatehistory(historyItem)
{
    db.transaction(
       function(tx) {
          tx.executeSql("UPDATE history SET title = ?, url = ?,  modified = ? WHERE id = ?",
                        [historyItem.title, historyItem.url, historyItem.modified, historyItem.id]);
       }
    )
}

// deletes a single history record
function deletehistory(id)
{
    db.transaction(
       function(tx) {
          tx.executeSql("DELETE FROM history WHERE id = ?", [id]);
       }
    )
}
function search(model)
{
    model.clear();
    if (searchcriteria === "") {
        model.clear();
        var sqlstringer = "SELECT id, title, url FROM history";
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
        var sqlstring = "SELECT id, title, url FROM history";
        sqlstring += " WHERE url LIKE '%" + searchcriteria + "%' OR title LIKE '%" + searchcriteria + "%'"
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
function readHistoryList(model)
{
    model.clear();
    var sqlstring = "SELECT id, title, url FROM history";

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
function readhistoryItem(id) {
    var data = {}
    db.readTransaction(
       function(tx) {
          var rs = tx.executeSql("SELECT * FROM notes WHERE id=?", [id])
          if(rs.rows.length === 1) {
             data = rs.rows.item(0)
          }
       }
    )
    return data;
}

// create a default history item
function defaultItem()
{
    return {title: "", url: "", modified: new Date()}
}


