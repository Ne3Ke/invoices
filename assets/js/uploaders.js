// * we need a slice of JavaScript that the client will invoke to
// * send a post request to the signed url with the signed form data

// the name S3 matches what we declared in our SimpleS3Upload module
let Uploaders = {};

Uploaders.S3 = function (entries, onViewError) {
  entries.forEach((entry) => {
    // Prepares an AJAX request
    let xhr = new XMLHttpRequest();
    onViewError(() => xhr.abort());
    xhr.onload = () =>
      xhr.status === 200 ? entry.progress(100) : entry.error();
    xhr.onerror = () => entry.error();

    xhr.upload.addEventListener("progress", (event) => {
      if (event.lengthComputable) {
        let percent = Math.round((event.loaded / event.total) * 100);
        if (percent < 100) {
          entry.progress(percent);
        }
      }
    });

    let url = entry.meta.url;
    xhr.open("PUT", url, true);
    xhr.send(entry.file);
  });
};

export default Uploaders;
