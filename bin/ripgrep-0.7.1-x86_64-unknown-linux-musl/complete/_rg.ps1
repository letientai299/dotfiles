
@('rg', './rg') | %{
    Register-ArgumentCompleter -Native -CommandName $_ -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        $command = '_rg'
        $commandAst.CommandElements |
            Select-Object -Skip 1 |
            %{
                switch ($_.ToString()) {

                    'ripgrep' {
                        $command += '_ripgrep'
                        break
                    }

                    default { 
                        break
                    }
                }
            }

        $completions = @()

        switch ($command) {

            '_rg' {
                $completions = @('-a', '-c', '-F', '-i', '-n', '-N', '-q', '-u', '-v', '-w', '-x', '-l', '-H', '-L', '-0', '-o', '-p', '-s', '-S', '-h', '-V', '-e', '-E', '-g', '-t', '-T', '-A', '-B', '-C', '-f', '-m', '-r', '-j', '-M', '--files', '--type-list', '--text', '--count', '--fixed-strings', '--ignore-case', '--line-number', '--no-line-number', '--quiet', '--unrestricted', '--invert-match', '--word-regexp', '--line-regexp', '--column', '--debug', '--files-with-matches', '--files-without-match', '--with-filename', '--no-filename', '--heading', '--no-heading', '--hidden', '--follow', '--mmap', '--no-messages', '--no-mmap', '--no-ignore', '--no-ignore-parent', '--no-ignore-vcs', '--null', '--only-matching', '--pretty', '--case-sensitive', '--smart-case', '--sort-files', '--vimgrep', '--help', '--version', '--regexp', '--color', '--colors', '--encoding', '--glob', '--iglob', '--type', '--type-not', '--after-context', '--before-context', '--context', '--context-separator', '--dfa-size-limit', '--file', '--ignore-file', '--max-count', '--max-filesize', '--maxdepth', '--path-separator', '--replace', '--regex-size-limit', '--threads', '--max-columns', '--type-add', '--type-clear')
            }

        }

        $completions |
            ?{ $_ -like "$wordToComplete*" } |
            Sort-Object |
            %{ New-Object System.Management.Automation.CompletionResult $_, $_, 'ParameterValue', $_ }
    }
}
