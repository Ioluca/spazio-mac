// Report the iCloud state of files and folders, read-only.
// Usage: osascript -l JavaScript stato_icloud.js [--solo-cartella] PATH...
// Runs on every Mac: it needs no developer tools.
ObjC.import('Foundation');

var MAX_ITEMS = 30000;

function resourceValue(url, key) {
  var value = Ref();
  return url.getResourceValueForKeyError(value, key, null) ? ObjC.unwrap(value[0]) : undefined;
}

function isUbiquitous(url) {
  return resourceValue(url, $.NSURLIsUbiquitousItemKey) === true;
}

function isDirectory(url) {
  return resourceValue(url, $.NSURLIsDirectoryKey) === true;
}

function summarize(path) {
  var manager = $.NSFileManager.defaultManager;
  var root = $.NSURL.fileURLWithPath(path);
  if (!manager.fileExistsAtPath(path)) return path + ' | non esiste';
  if (!isUbiquitous(root)) return path + ' | iCloud: no';

  var cloudOnlyStatus = ObjC.unwrap($.NSURLUbiquitousItemDownloadingStatusNotDownloaded);
  var items = 0, notUploaded = 0, unknown = 0, cloudOnly = 0;
  // A missing value is not a yes: only an explicit true proves the item is in iCloud.
  var check = function (url) {
    items += 1;
    var uploaded = resourceValue(url, $.NSURLUbiquitousItemIsUploadedKey);
    if (uploaded === undefined) unknown += 1;
    else if (uploaded !== true) notUploaded += 1;
    if (resourceValue(url, $.NSURLUbiquitousItemDownloadingStatusKey) === cloudOnlyStatus) cloudOnly += 1;
  };
  var isPackage = function (url) {
    return resourceValue(url, $.NSURLIsPackageKey) === true;
  };

  if (isDirectory(root) && !isPackage(root)) {
    var walker = manager.enumeratorAtPath(path);
    var relative;
    var visited = 0;
    while ((relative = walker.nextObject) && !relative.isNil()) {
      // About 300 items per second: past this point the check would outlive any shell timeout.
      visited += 1;
      if (visited > MAX_ITEMS) {
        return path + ' | CONTROLLO INTERROTTO dopo ' + MAX_ITEMS + ' elementi: voce non verificata, ' +
          'controlla le sottocartelle una per una';
      }
      var name = ObjC.unwrap(relative);
      var leaf = name.split('/').pop();
      if (leaf === '.DS_Store' || leaf.indexOf('._') === 0) continue;
      var item = root.URLByAppendingPathComponent(name);
      if (isPackage(item)) {
        // iCloud tracks a package as one item: its inner files report no state.
        walker.skipDescendants;
        check(item);
      } else if (isDirectory(item)) {
        // The walker skips an unreadable folder in silence: count it as not verified.
        if (!manager.isReadableFileAtPath(path + '/' + name)) {
          items += 1;
          unknown += 1;
        }
      } else {
        check(item);
      }
    }
  } else {
    check(root);
  }
  return path + ' | iCloud: si | elementi ' + items + ' | non caricati ' + notUploaded +
    ' | stato sconosciuto ' + unknown + ' | solo nel cloud ' + cloudOnly;
}

function run(argv) {
  var folderOnly = argv[0] === '--solo-cartella';
  var paths = folderOnly ? argv.slice(1) : argv;
  if (paths.length === 0) return 'Uso: osascript -l JavaScript stato_icloud.js [--solo-cartella] PERCORSO...';
  return paths.map(function (path) {
    if (!folderOnly) return summarize(path);
    return path + ' | iCloud: ' + (isUbiquitous($.NSURL.fileURLWithPath(path)) ? 'si' : 'no');
  }).join('\n');
}
