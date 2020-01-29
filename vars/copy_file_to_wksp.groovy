def inputGetFile(Map pipelineParams, String savedfile = null) {
    def filedata = null
    def filename = null
    // Get file using input step, will put it in build directory
    // the filename will not be included in the upload data, so optionally allow it to be specified
    ansiColor('xterm') {
        String ANSI_GREEN = "\u001B[32m"
        String ANSI_NORMAL = "\u001B[0m"
        String ANSI_BOLD = "\u001B[1m"
        String ANSI_RED = "\u001B[31m"
        String ANSI_YELLOW = "\u001B[33m"

    if (savedfile == null) {
        def inputFile = input message: 'Upload file', parameters: [file(name: 'library_data_upload'), string(name: 'filename', defaultValue: 'token.xlsx')]
        filedata = inputFile['library_data_upload']
        filename = inputFile['filename']
    } else {
        def inputFile = input message: 'Upload file', parameters: [file(name: 'library_data_upload')]
        filedata = inputFile
        filename = savedfile
    }

    // Read contents and write to workspace
    writeFile(file: filename, encoding: 'Base64', text: filedata.read().getBytes().encodeBase64().toString())
    filedata.delete()

        stage('ansible-run') {
         println pipelineParams

         inventory_path = "${pipelineParams.currentWs}/ansible/inventory/$pipelineParams.env"
          sh """
             cp ${pipelineParams.currentWs}/tokens.xlsx ${pipelineParams.currentWs}/data_input/
                     ansible-playbook -i ${inventory_path} -c local $pipelineParams.ansiblePlaybook $pipelineParams.ansibleExtraArgs
             """

        }

    }
}
