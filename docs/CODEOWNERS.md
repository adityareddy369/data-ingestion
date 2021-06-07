# This is a comment.
# Each line is a file pattern followed by one or more owners.

# These owners will be the default owners for everything in
# the repo. 
*       @jamesgrizzle, @brandon-bird-kr, @amit-kumar-kr, @robert-edlund-kr

# Order is important; the last matching pattern takes the most
# precedence. When someone opens a pull request that only
# modifies TF files, only @@amit-kumar-kr and not the global
# owner(s) will be requested for a review.
 terraform/*.tf    @amit-kumar-kr, @robert-edlund-kr

# You can also use email addresses if you prefer. They'll be
# used to look up users just like we do for commit author
# emails.
# *.go docs@example.com

# In this example, @doctocat owns any files in the build/logs
# directory at the root of the repository and any of its
# subdirectories.
# /build/logs/ @doctocat

# The `docs/*` pattern will match files like
# `docs/getting-started.md` but not further nested files like
# `docs/build-app/troubleshooting.md`.
docs/*  @jamesgrizzle, @robert-edlund-kr
ci-cd/*  @jamesgrizzle, @robert-edlund-kr

# In this example, @octocat owns any file in an apps directory
# anywhere in your repository.
# apps/ @octocat

# In this example, @doctocat owns any file in the `/docs`
# directory in the root of your repository.
# /docs/ @doctocat