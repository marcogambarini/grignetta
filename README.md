# grignetta
Prototyping and eventually building a plugin for de-clipping audio files that is open source and easy to use

Plan:
- prototyping in Matlab/Octave 
  (note: keep code compatible with Octave, try to avoid using special Matlab toolboxes, so that porting will be easier
   and anybody can collaborate)

- porting in Python? (larger possible user/collaborator base? but still Octave is simple, lightweight and open-source, so...) 

- once the algorithm is established, build a vst plugin for use in DAWs


The main testing file at the moment is prova_restore.m. Try that. It already sounds reasonably ok, but there is large room for improvement, and for trying different strategies (Kalman filtering? Autoregressive models? Machine learning (this is how some big players say they are doing it, but we can't know for sure)?)


Audio files are raw lavalier recordings from a movie currently in production: https://www.imdb.com/title/tt10206898/, for which this work will be used

Many comments in the code are still in italian, sorry
