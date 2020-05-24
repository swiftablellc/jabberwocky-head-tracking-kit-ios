## Release (Swiftable Developers)

1. Navigate to jabberwocky-head-tracking-kit-ios directory
    * `git pull`
2. Update the JabberwockyHTKit.podspec file.
    * Modify the version number in spec.version.
    * Modify the swift_version if needed in spec.swift_version.
3. Prepare Release Commit
    * `git add *` 
    * `git commit -m 'Preparing <version> for release.'`
4. Tag version
    * `git tag -a <version> -m 'Tagging Release Version <version>'`
    * `git push origin --tags`
5. Do a pod spec lint from the version directory
    * `pod spec lint --verbose --sources="https://github.com/swiftablellc/jabberwocky-specs-repo.git" JabberwockyHTKit.podspec`
6. Upload to the `jabberwocky-specs-repo` Pods Repo
    * `pod repo push jabberwocky-specs-repo JabberwockyHTKit.podspec`
    * If you don't have the repo installed yet: `pod repo add jabberwocky-specs-repo https://github.com/swiftablellc/jabberwocky-specs-repo.git`
7. Pod spec lint for CocoaPods
    * `pod lib lint`
8. Upload to CocoaPods
    * `pod trunk push JabberwockyHTKit.podspec`
9. **IMPORTANT** - Finish pushing the commit to master.
    * `git push origin master`
    * We don't do this before, because we can amend the commit until the podspec lint succeeds.
