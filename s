import com.jcraft.jsch.*;
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;

public class SSHSwingTerminal {

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new SSHSwingTerminal().start());
    }

    private void start() {
        // Prompt for SSH credentials
        String username = promptForInput("Enter SSH Username:", "Username");
        if (username == null) return;

        String password = promptForPassword("Enter SSH Password:", "Password");
        if (password == null) return;

        String host = promptForInput("Enter SSH Host (IP Address):", "Host");
        if (host == null) return;

        // Setup GUI
        JFrame frame = new JFrame("SSH Terminal");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(800, 600);

        JTextArea terminalArea = new JTextArea();
        terminalArea.setFont(new Font("Monospaced", Font.PLAIN, 14));
        terminalArea.setEditable(false);
        terminalArea.setBackground(Color.BLACK);
        terminalArea.setForeground(Color.WHITE);
        terminalArea.setCaretColor(Color.WHITE);

        JScrollPane scrollPane = new JScrollPane(terminalArea);
        frame.add(scrollPane, BorderLayout.CENTER);
        frame.setVisible(true);

        // Initialize SSH connection in a separate thread
        new Thread(() -> initializeSSHSession(username, password, host, terminalArea)).start();
    }

    private void initializeSSHSession(String username, String password, String host, JTextArea terminalArea) {
        try {
            JSch jsch = new JSch();
            Session session = jsch.getSession(username, host, 22);
            session.setPassword(password);

            // Disable host key checking for simplicity
            session.setConfig("StrictHostKeyChecking", "no");
            terminalArea.append("Connecting to " + host + "...\n");
            session.connect();
            terminalArea.append("Connected to " + host + ".\n");

            ChannelShell channel = (ChannelShell) session.openChannel("shell");
            PipedInputStream pipedIn = new PipedInputStream();
            PipedOutputStream pipedOut = new PipedOutputStream(pipedIn);

            channel.setInputStream(pipedIn);
            InputStream channelOut = channel.getInputStream();

            channel.connect();

            // Set up key listener for terminal input
            setupTerminalInput(terminalArea, pipedOut);

            // Read output from the SSH channel and display in terminal area
            readChannelOutput(channelOut, terminalArea);

            // Close resources when done
            channel.disconnect();
            session.disconnect();
            terminalArea.append("\nDisconnected from " + host + ".\n");
        } catch (Exception e) {
            e.printStackTrace();
            SwingUtilities.invokeLater(() -> JOptionPane.showMessageDialog(null, "Error: " + e.getMessage(), "Connection Error", JOptionPane.ERROR_MESSAGE));
        }
    }

    private void setupTerminalInput(JTextArea terminalArea, OutputStream out) {
        terminalArea.addKeyListener(new KeyAdapter() {
            @Override
            public void keyTyped(KeyEvent e) {
                try {
                    char c = e.getKeyChar();
                    out.write(c);
                    out.flush();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            }

            @Override
            public void keyPressed(KeyEvent e) {
                try {
                    int code = e.getKeyCode();
                    switch (code) {
                        case KeyEvent.VK_BACK_SPACE:
                            out.write(0x7F); // DEL character
                            break;
                        case KeyEvent.VK_ENTER:
                            out.write('\n');
                            break;
                        case KeyEvent.VK_TAB:
                            out.write('\t');
                            break;
                        case KeyEvent.VK_UP:
                            out.write("\033[A".getBytes());
                            break;
                        case KeyEvent.VK_DOWN:
                            out.write("\033[B".getBytes());
                            break;
                        case KeyEvent.VK_LEFT:
                            out.write("\033[D".getBytes());
                            break;
                        case KeyEvent.VK_RIGHT:
                            out.write("\033[C".getBytes());
                            break;
                        default:
                            // For other control keys, ignore or handle as needed
                            break;
                    }
                    out.flush();
                    e.consume();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            }
        });

        // Request focus on the terminal area to capture input
        SwingUtilities.invokeLater(terminalArea::requestFocusInWindow);
    }

    private void readChannelOutput(InputStream in, JTextArea terminalArea) {
        try {
            byte[] buffer = new byte[1024];
            int read;
            while ((read = in.read(buffer)) != -1) {
                String output = new String(buffer, 0, read);
                SwingUtilities.invokeLater(() -> {
                    terminalArea.append(output);
                    terminalArea.setCaretPosition(terminalArea.getDocument().getLength());
                });
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private String promptForInput(String message, String title) {
        return SwingUtilities.invokeAndWait(() -> JOptionPane.showInputDialog(null, message, title, JOptionPane.PLAIN_MESSAGE));
    }

    private String promptForPassword(String message, String title) {
        JPasswordField passwordField = new JPasswordField();
        int option = JOptionPane.showConfirmDialog(null, passwordField, title, JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
        if (option == JOptionPane.OK_OPTION) {
            return new String(passwordField.getPassword());
        }
        return null;
    }
}
