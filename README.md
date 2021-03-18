# grignetta
Prototyping and eventually building a plugin for de-clipping audio files that is open source and easy to use

Plan:
- prototyping in Matlab/Octave 
  (note: keep code compatible with Octave, try to avoid using special Matlab toolboxes, so that porting will be easier
   and anybody can collaborate)

- once the algorithm is established, build a vst plugin for use in DAWs


The main testing file at the moment is prova_restore.m. Try that. It already sounds reasonably ok, but there is large room for improvement, and for trying different strategies. See for example

http://reports.ias.ac.in/report/18659/a-comparison-of-different-methods-for-audio-declipping

https://spade.inria.fr/#About_spade

The algorithm is quite naive. It is a 2-step process:

(1) recognition: it finds clipped samples following the criteria

  (a) sample value greater than threshold value peakThreshold
  
  (b) at least numThreshold adjacent samples with amplitudes closer to each other than diffThreshold
  
(2) restoration: clipped areas are substituted by least-square fit of parabolas (peaks) (this sounds so dumb but it's working!)

At the moment the script runs at about 3x realtime on a single core on my laptop. I am planning on trying to parallelize it, but since I will use it for batch cleaning of files I will probably just run multiple instances in parallel - so parallelization is not a priority right now.

Audio files are raw lavalier recordings from a movie currently in production (soon in post-production!!): https://www.imdb.com/title/tt10206898/, for which this work will be used.

Many comments in the code are still in italian, sorry.
