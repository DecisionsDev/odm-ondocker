# Contributing to a ODMDev project
_Do you have a contribution?  We welcome contributions, but please ensure that you read the following information
before issuing a pull request.  Also refer back to this document as a checklist before issuing your pull request.
This will save time for everyone._

# Before You Start

## Understanding the Basics

If you don't understand what a *pull request* is, or how to submit one, please refer to the [help documentation](https://help.github.com/articles/about-pull-requests/)
provided by GitHub.

## Is It Really a Support Issue

If you aren't sure if your contribution is needed or necessary, please visit the [support forum][ml-users] before attempting to
submit a pull request or a ticket.

## Search Project Bug Base

We require every commit, bug or enhancement to be tracked via our [bug database][].  It is useful, before you get too
far, that you have checked that your issue isn't already known, otherwise addressed?  If you think it is a valid defect or
enhancement, please open a new ticket before submitting your pull request.

## Discuss Non-Trivial Contributions with the Committers

If your desired contribution is more than a non-trivial fix, you should discuss it on the
[contributor's mailing list](mailto:odmdev_open_source_user@wwpdl.vnet.ibm.com).  If you currently are not a member, you can request to be added.


## New features

Please raise any new feature requests on the project's issue tracker.

### Coding standards

Please ensure you follow the coding standards used throughout the existing code base. Some basic rules include:

 - All files must have the Apache license in the header.
 - Indent with 4 spaces, no tabs. No arguments.
 - Opening brace on same line as `if`/`for`/`function`/etc, closing brace on its own line.

### Contributor License Agreement

In order for us to accept pull requests, you must declare that you wrote the code or, at least, have the right to contribute it to the repo under the open source licence of the project in the repo. It's dead easy...

1. Read this (from [developercertificate.org](http://developercertificate.org/)):

  ```
  Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2025 The Linux Foundation and its contributors.
660 York Street, Suite 102,
San Francisco, CA 94110 USA

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.


Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
  ```

2. If you can certify that it is true, sign off your `git commit` with a message like this:
  ```
  Signed-off-by: Laura Cowen <laura.cowen@email.com>
  ```
  You must use your real name (no pseudonyms or anonymous contributions, sorry).

  Instead of typing that in every git commit message, your Git tools might let you automatically add the details for you. If you configure them to do that, when you issue the `git commit` command, just add the `-s` option.

If you are an IBMer, please contact us directly as the contribution process is
slightly different.



## Test Cases

If the pull request changes the functional behaviour or is fixing a defect, the unit test cases should be modified to
reflect this.  The committer reviewing your pull request is likely to request the appropriate changes in the test
cases.
It is expected that you will have tested your changes against the existing test cases and appropriate platforms prior to
submitting your pull request.

## Licensing

All of your submissions are licensed under Apache 2.0 License.

# Submitting a Pull Request

The following are the general steps you should follow in creating a pull request.  Subsequent pull requests only need
to follow step 3 and beyond:

1. Fork the repository on GitHub
2. Clone the forked repository to your machine
3. Create a "feature" branch in your local repository
4. Make your changes and commit them to your local repository
5. Rebase and push your commits to your GitHub remote fork/repository
6. Issue a Pull Request to the official repository
7. Your Pull Request is reviewed by a committer and merged into the repository

*Note* While there are other ways to accomplish the steps using other tools, the examples here will assume the most
actions will be performed via the `git` command line.

## 1. Fork the Repository

When logged into your GitHub account, and you are viewing one of the main repositories, you will see the *Fork* button.
Clicking this button will show you which repositories your can fork to.  Choose your own account.  Once the process
finishes, you will have your own repository that is "forked" from the GitHub one.

Forking is a GitHub term and not a git term.  Git is a wholly distributed source control system and simply worries
about local and remote repositories and allows you to manage your code against them.  GitHub then adds this additional
layer of structure of how repositories can relate to each other.

## 2. Clone the Forked Repository

Once you have successfully forked your repository, you will need to clone it locally to your machine:

```bash
$ git clone git@github.com:username/odm-ondocker.git
```

This will clone your fork to your current path in a directory named `odm-ondocker`.

You should also setup the `upstream` repository.  This will allow you to take changes from the "master" repository
and merge them into your local clone and then push them to your GitHub fork:

```bash
$ cd odm-ondocker
$ git remote add upstream git@github.com:lgrateau/odm-ondocker.git
$ git fetch upstream
```

Then you can retrieve upstream changes and rebase on them into your code like this:

```bash
$ git pull --rebase upstream master
```

For more information on maintaining a fork, please see the GitHub Help article [Fork a Repo][] and information on
[rebasing][] from git.

## 3. Create a Branch

The easiest workflow is to keep your master branch in sync with the upstream branch and do not locate any of your own
commits in that branch.  When you want to work on a new feature, you then ensure you are on the master branch and create
a new branch from there.  While the name of the branch can be anything, it can often be easy to use the ticket number
you might be working on.  For example:

```bash
$ git checkout -b t12 master
Switched to a new branch 't12'
```

You will then be on the feature branch.  You can verify what branch you are on like this:

```bash
$ git status
# On branch t12
nothing to commit, working directory clean
```

## 4. Make Changes and Commit

Now you just need to make your changes.  Once you have finished your changes (and tested them) you need to commit them
to your local repository (assuming you have staged your changes for committing):

```bash
$ git status
# On branch t12345
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#        modified:   somefile.js
#
$ git commit -m "Corrects some defect, fixes #12"
[t12 0000000] Corrects some defect, fixes #12
 1 file changed, 2 insertions(+), 2 deletions(-)
```

## 5. Rebase and Push Changes

If you have been working on your contribution for a while, the upstream repository may have changed.  You may want to
ensure your work is on top of the latest changes so your pull request can be applied cleanly:

```bash
$ git pull --rebase upstream master
```

When you are ready to push your commit to your GitHub repository for the first time on this branch you would do the
following:

```bash
$ git push -u origin t12
```

After the first time, you simply need to do:

```bash
$ git push
```

## 6. Issue a Pull Request

In order to have your commits merged into the main repository, you need to create a pull request.  The instructions for
this can be found in the GitHub Help Article [Creating a Pull Request][].  Essentially you do the following:

1. Go to the site for your repository.
2. Click the Pull Request button.
3. Select the feature branch from your repository.
4. Enter a title and description of your pull request.
5. Review the commit and files changed tabs.
6. Click `Send Pull Request`

You will get notified about the status of your pull request based on your GitHub settings.

## 7. Request is Reviewed and Merged

Your request will be reviewed.  It may be merged directly, or you may receive feedback or questions on your pull
request.


[help documentation]: http://help.github.com/send-pull-requests
[ml-users]: mailto:odmdev_open_source_user@wwpdl.vnet.ibm.com
[Creating a Pull Request]: https://help.github.com/articles/creating-a-pull-request
[Fork a Repo]: https://help.github.com/articles/fork-a-repo
[coding guidelines]: https://github.com/ibm-js/sdk/blob/master/GUIDELINES.md
[interactive rebase]: http://git-scm.com/book/en/Git-Tools-Rewriting-History#Changing-Multiple-Commit-Messages
[rebasing]: http://git-scm.com/book/en/Git-Branching-Rebasing
