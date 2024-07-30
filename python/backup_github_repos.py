## FILE: backup_github_repos.py
##
## DESCRIPTION: Backs up GitHub repos in an account.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: python3 backup_github_repos.py
##

import requests
import json, os
import shutil
# json, os are in standard library

backupDir = "/tmp/githubBackup"
backupZip = "gitbackup.zip"
# add datestamp in future version
listRepoNames = []
repoOwner = "chrisbuckleycode"
GitHubRepoListUrl = f"https://api.github.com/users/{repoOwner}/repos"

GitHubresponse = requests.get(GitHubRepoListUrl)

json_data = json.loads(GitHubresponse.text)

# get repo names if they have a clone_url
for repo in GitHubresponse.json():
    if repo['clone_url']:
        listRepoNames.append(repo['name'])

# remove temp dir if left over from previously
try:
  os.system("rm -rf /tmp/githubBackup")
except:
  pass

# create temp dir
os.system(f"mkdir {backupDir}")

for name in listRepoNames:
    print(f"\nCloning: https://github.com/{repoOwner}/{name}")
    os.system(f"git clone https://github.com/{repoOwner}/{name}.git {backupDir}/{name}")
# add gists in future version

# standard library is messy for zipping, this is cleaner!
# shutil.make_archive(backupZip, 'zip', backupDir)

# os alternative if not using shutil library
os.system(f"zip -r {backupZip} {backupDir}")

print(f"\nBackup archive {backupZip} created")
