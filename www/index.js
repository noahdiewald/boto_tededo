import 'bulma/css/bulma.css';
import { Elm } from "../src/Main.elm";
// import * as serviceWorker from './serviceWorker';
import * as seed from './seed';

const PouchDB = require('pouchdb-browser');
const pouchDB = PouchDB.default.defaults();

var db = new pouchDB('bototededo');

db.info().then(function (info) {
  console.log(info);

  if (info.doc_count == 0) {
    db.bulkDocs(seed.seeddata);
  }
});

const app = Elm.Main.init({ node: document.getElementById("root") });

app.ports.reqAllDocs.subscribe(function() {
  db.allDocs({include_docs: true, descending: true}, function(err, doc) {
    console.log("got here");
    app.ports.recAllDocs.send(JSON.stringify(doc.rows));
  });
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
// serviceWorker.unregister();

