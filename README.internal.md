## Update Cocoapod

* `pod repo add QuickBuildKit https://github.com/vinced45/xxx.git` Only if adding new PodSpec

* `git add .`
* `git commit -m "updated PodSpec"`
* `git tag 0.0.1`
* `git push origin master --tags`
* `pod repo push QuickBuildKit QuickBuildKit.podspec --allow-warnings`
