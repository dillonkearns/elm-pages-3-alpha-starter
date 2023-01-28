

const mixToSong = setName => mix => {
  return {
    name          : mix.title,
    artist        : "DJ Dope Inc.",
    album         : setName,
    url           : mix.url,
    cover_art_url : mix.url.replace(/.mp3/, ".jpg")
  };
};

export default {
  load: async function (elmLoaded) {
      const app = await elmLoaded;
      app.ports.amplitude.subscribe(function(setList) {
          const initObj =
              { songs: setList.mixen.map(mixToSong(setList.set)),
                callbacks: {
                    play: () => {
                        document.getElementById('amplitude-left').classList.add('playing');
                    },
                    pause: () => {
                        document.getElementById('amplitude-left').classList.remove('playing');
                    }
                },
              };
          let anode = Amplitude.getAnalyser();
          if (anode) {
            Amplitude.pause();
            anode.context.close().then(() => {
                  Amplitude.init(initObj);
            });
          } else {
                  Amplitude.init(initObj);
          }
      });
  },
  flags: function () {
    return null;
  },
};
