## POC Jenkins templating

### folder structure for shared libraries

```
(root)
+- src                     # Groovy source files
|   +- org
|       +- foo
|           +- Bar.groovy  # for org.foo.Bar class
+- vars
|   +- foo.groovy          # for global 'foo' variable
|   +- foo.txt             # help for 'foo' variable
+- resources               # resource files (external libraries only)
|   +- org
|       +- foo
|           +- bar.json    # static helper data for org.foo.Bar
```

### Configuring global vars
Manage Jenkins » Configure System » Global Pipeline Libraries

> Can have both folder level and global shared libs.

in the variables folder, we'll have dev, staging, prod

in the Jenkinsfile

library 'prod'

will inherit all the prod vars


ref: 
https://jenkins.io/doc/book/pipeline/shared-libraries/#defining-declarative-pipelines
https://stackoverflow.com/questions/44070068/jenkins-pipeline-template
