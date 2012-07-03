# An experiment in lexicase selection

Lee Spector recently started talking up [Lexicase Selection](http://faculty.hampshire.edu/lspector/pubs/wk09p4-spector.pdf) [**PDF link**] in his work, and I've found it useful in the projects I'm writing up for [the book](http://leanpub.com/pragmaticGP).

A few years back I had a "completely unrelated" idea, or rather more of a speculation: that in linear regression (and more generally symbolic regression) we could get away with using *multiobjective* measures to determine which model beats which other: instead of using aggregate statistics over the set of residuals, we could use multiobjective domination over the *vector* of residuals.

If this doesn't mean much too you, that's OK. It's crazy, because of course everybody knows when you do multiobjective sorting in anything over about 10 dimensions, you can't do any selection at all. Everything is better at *something*, and all the density in those high-dimensional spaces is near the surface of a volume, not evenly distributed.

Anyway, I wondered tonight whether using *lexicase selection* over the absolute errors, you could avoid this sphere hardening problem.

Yes.

This is a quick sketch, for now. More in a few days.