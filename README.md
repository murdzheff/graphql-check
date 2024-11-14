* WHAT IS THAT?

One of my custom build containers that scraped a website for our employees at my current company.

* USAGE

After you build/pull the image you have to run it with:

`docker run -d -e DOMAIN="<some domain with email functionality>" -e COOKIE="Cookie taken from the Ledger website" murdzheff/graphql-scan:latest`
