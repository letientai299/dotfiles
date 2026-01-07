// This use https://github.com/dkandalov/live-plugin
// to add caller ino in  C# LoggerMessage template and function definition
// via IDE intention and inspection.

import com.intellij.codeInsight.intention.impl.BaseIntentionAction
import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.actionSystem.CommonDataKeys
import com.intellij.openapi.command.WriteCommandAction
import com.intellij.openapi.editor.Editor
import com.intellij.openapi.project.Project
import com.intellij.psi.PsiFile
import static liveplugin.PluginUtil.*

// Shared utility for LoggerMessage transformations
class LoggerMessageHelper {
    static final String MARKER = "[LoggerMessage("
    static final String USING_STATEMENT = "using System.Runtime.CompilerServices;"

    static void ensureUsingStatement(def doc) {
        if (!doc.text.contains("System.Runtime.CompilerServices")) {
            doc.insertString(0, USING_STATEMENT + "\n")
        }
    }

    static int findLoggerMessageIndex(String text, int caretOffset) {
        // Extend search to include cases where caret is within the marker
        def searchEnd = Math.min(caretOffset + MARKER.length(), text.length())
        text.take(searchEnd).lastIndexOf(MARKER)
    }

    static List<Integer> findAllLoggerMessageIndices(String text) {
        def indices = []
        def idx = 0
        while ((idx = text.indexOf(MARKER, idx)) != -1) {
            indices << idx
            idx += MARKER.length()
        }
        indices
    }

    static boolean needsCallerMemberName(String text, int startIdx) {
        def afterAttr = text.drop(startIdx)
        def parenIdx = afterAttr.indexOf(')', 50)
        parenIdx != -1 && !afterAttr.take(parenIdx + 1).contains('func')
    }

    static void applyTransformation(def doc, int idx) {
        def quoteIdx = doc.text.indexOf('"', idx)
        if (quoteIdx == -1) return

        doc.insertString(quoteIdx + 1, "[{func}] ")

        // Find the closing ] of the attribute, then find the method's opening (
        def attrCloseIdx = doc.text.indexOf(']', idx)
        if (attrCloseIdx == -1) return

        def methodOpenParenIdx = doc.text.indexOf('(', attrCloseIdx)
        if (methodOpenParenIdx == -1) return

        // Check if there are existing args in the method
        def methodCloseParenIdx = doc.text.indexOf(');', methodOpenParenIdx)
        if (methodCloseParenIdx == -1) return

        def hasExistingArgs = doc.text.substring(methodOpenParenIdx + 1, methodCloseParenIdx).trim()
        def insertion = hasExistingArgs ? ', [CallerMemberName] string func = ""' : '[CallerMemberName] string func = ""'
        doc.insertString(methodCloseParenIdx, insertion)
    }

    static void applyToCurrent(Project project, Editor editor) {
        def idx = findLoggerMessageIndex(editor.document.text, editor.caretModel.offset)
        if (idx == -1) return
        WriteCommandAction.runWriteCommandAction(project) {
            ensureUsingStatement(editor.document)
            applyTransformation(editor.document, findLoggerMessageIndex(editor.document.text, editor.caretModel.offset))
        }
    }

    static void applyToAll(Project project, Editor editor) {
        WriteCommandAction.runWriteCommandAction(project) {
            def doc = editor.document
            ensureUsingStatement(doc)
            findAllLoggerMessageIndices(doc.text)
                .findAll { needsCallerMemberName(doc.text, it) }
                .reverse()
                .each { applyTransformation(doc, it) }
        }
    }

    static boolean isCurrentAvailable(Editor editor) {
        def idx = findLoggerMessageIndex(editor.document.text, editor.caretModel.offset)
        idx != -1 && needsCallerMemberName(editor.document.text, idx)
    }

    static boolean isAnyAvailable(Editor editor) {
        findAllLoggerMessageIndices(editor.document.text)
            .any { needsCallerMemberName(editor.document.text, it) }
    }
}

// Apply to current LoggerMessage at caret
class AddCallerMemberNameCurrentIntention extends BaseIntentionAction {
    AddCallerMemberNameCurrentIntention() { setText("Add [CallerMemberName]") }
    @Override String getFamilyName() { "LoggerMessage" }
    @Override boolean isAvailable(Project project, Editor editor, PsiFile file) { LoggerMessageHelper.isCurrentAvailable(editor) }
    @Override void invoke(Project project, Editor editor, PsiFile file) { LoggerMessageHelper.applyToCurrent(project, editor) }
}

// Apply to all LoggerMessages in file
class AddCallerMemberNameAllIntention extends BaseIntentionAction {
    AddCallerMemberNameAllIntention() { setText("Add [CallerMemberName] to all in file") }
    @Override String getFamilyName() { "LoggerMessage" }
    @Override boolean isAvailable(Project project, Editor editor, PsiFile file) { LoggerMessageHelper.isAnyAvailable(editor) }
    @Override void invoke(Project project, Editor editor, PsiFile file) { LoggerMessageHelper.applyToAll(project, editor) }
}

registerIntention(pluginDisposable, new AddCallerMemberNameCurrentIntention())
registerIntention(pluginDisposable, new AddCallerMemberNameAllIntention())

if (!isIdeStartup) show("Loaded 'Add CallerMemberName to LoggerMessage' intention")

