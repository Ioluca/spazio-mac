// Remove the local copy of iCloud items, keeping them in iCloud ("Rimuovi download").
// Usage: osascript -l JavaScript rimuovi_download.js PATH...
// Files not yet uploaded are skipped: they exist only on this Mac.
// A folder is walked file by file; a package such as a Camtasia project is one item.
ObjC.import('Foundation');

function resourceValue(url, key) {
  var value = Ref();
  return url.getResourceValueForKeyError(value, key, null) ? ObjC.unwrap(value[0]) : undefined;
}

function run(argv) {
  if (argv.length === 0) return 'Uso: osascript -l JavaScript rimuovi_download.js PERCORSO...';
  var manager = $.NSFileManager.defaultManager;
  var removed = 0, skipped = 0, failed = 0;

  var evict = function (url) {
    if (resourceValue(url, $.NSURLUbiquitousItemIsUploadedKey) !== true) {
      skipped += 1;
      return;
    }
    if (manager.evictUbiquitousItemAtURLError(url, null)) removed += 1;
    else failed += 1;
  };

  argv.forEach(function (path) {
    var root = $.NSURL.fileURLWithPath(path);
    if (resourceValue(root, $.NSURLIsUbiquitousItemKey) !== true) {
      skipped += 1;
      return;
    }
    var isFolder = resourceValue(root, $.NSURLIsDirectoryKey) === true;
    var isPackage = resourceValue(root, $.NSURLIsPackageKey) === true;
    if (!isFolder || isPackage) {
      evict(root);
      return;
    }
    var walker = manager.enumeratorAtPath(path);
    var relative;
    while ((relative = walker.nextObject) && !relative.isNil()) {
      var name = ObjC.unwrap(relative);
      var leaf = name.split('/').pop();
      if (leaf === '.DS_Store' || leaf.indexOf('._') === 0) continue;
      var item = root.URLByAppendingPathComponent(name);
      if (resourceValue(item, $.NSURLIsPackageKey) === true) {
        walker.skipDescendants;
        evict(item);
      } else if (resourceValue(item, $.NSURLIsDirectoryKey) !== true) {
        evict(item);
      }
    }
  });
  return 'tolti dal Mac ' + removed + ' | saltati ' + skipped + ' | errori ' + failed;
}
