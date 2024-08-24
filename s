import javax.swing.*;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

private String promptForInput(String message, String title) {
    FutureTask<String> task = new FutureTask<>(() -> JOptionPane.showInputDialog(null, message, title, JOptionPane.PLAIN_MESSAGE));
    SwingUtilities.invokeAndWait(task);
    try {
        return task.get();
    } catch (InterruptedException | ExecutionException e) {
        e.printStackTrace();
        return null;
    }
}

private String promptForPassword(String message, String title) {
    FutureTask<String> task = new FutureTask<>(() -> {
        JPasswordField passwordField = new JPasswordField();
        int option = JOptionPane.showConfirmDialog(null, passwordField, title, JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
        if (option == JOptionPane.OK_OPTION) {
            return new String(passwordField.getPassword());
        }
        return null;
    });
    SwingUtilities.invokeAndWait(task);
    try {
        return task.get();
    } catch (InterruptedException | ExecutionException e) {
        e.printStackTrace();
        return null;
    }
}
