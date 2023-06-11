#!/usr/bin/env bash

# Description: search r/kubernetes on Reddit, from the command line.

# Convert script arguments to url suffix
search_terms=$(IFS='%'; echo "$*")

# IFS can only handle one char, so using sed after to replace '%' with '%20'
search_terms=$(echo "$search_terms" | sed 's/%/%20/g')

url="https://www.reddit.com/r/kubernetes/search/?sort=comments&t=year&q=$search_terms"

# Open the URL in the default browser
xdg-open "$url"
