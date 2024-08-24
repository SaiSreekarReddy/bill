import com.jcraft.jsch.*;
import javax.swing.*;
import java.awt.*;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.regex.Pattern;
import java.util.Scanner;

public class SSHSwingTerminal {

    public static void main(String[] args) {
        // Hardcoded username and password
        String username = "your_username";
        String password = "your_password";

        // Create and set up the window.
        JFrame frame = new JFrame("SSH Terminal");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(800, 600);  // Larger size for better interaction

        // Create a text area for the terminal output
        JTextArea terminalArea = new JTextArea();
        terminalArea.setFont(new Font("Monospaced", Font.PLAIN, 14));  // Use monospaced font for terminal look
        terminalArea.setEditable(false);
        terminalArea.setLineWrap(false);  // Disable line wrapping for terminal-like behavior
        terminalArea.setWrapStyleWord(false);
        JScrollPane scrollPane = new JScrollPane(terminalArea);

        // Create a text field for command input
        JTextField commandField = new JTextField();
        commandField.setFont(new Font("Monospaced", Font.PLAIN, 14));  // Match font for consistency

        // Create a panel to hold components
        JPanel panel = new JPanel(new BorderLayout());
        frame.add(panel);

        panel.add(scrollPane, BorderLayout.CENTER);
        panel.add(commandField, BorderLayout.SOUTH);

        // Display the window.
        frame.setVisible(true);

        // Prompt the user for the IP address
        String host = JOptionPane.showInputDialog(null, "Enter the IP address of the server:", "Server IP", JOptionPane.PLAIN_MESSAGE);

        if (host == null || host.trim().isEmpty()) {
            JOptionPane.showMessageDialog(panel, "No IP address provided. Exiting.", "Error", JOptionPane.ERROR_MESSAGE);
            System.exit(1);
        }

        try {
            // Set up JSch and session
            JSch jsch = new JSch();
            Session session = jsch.getSession(username, host, 22);
            session.setPassword(password);

            // Avoid asking for key confirmation
            session.setConfig("StrictHostKeyChecking", "no");

            // Connect to the server
            session.connect();

            // Open a channel for executing commands
            ChannelShell channel = (ChannelShell) session.openChannel("shell");
            channel.setPty(true);  // Enable pseudo-terminal (PTY) for proper terminal emulation
            channel.setOutputStream(System.out);
            InputStream in = channel.getInputStream();
            OutputStream out = channel.getOutputStream();
            channel.connect();

            // Send the sudo su command
            out.write(("sudo su\n").getBytes());
            out.flush();

            // Handle the sudo password prompt
            new Thread(() -> {
                try (Scanner scanner = new Scanner(in)) {
                    while (scanner.hasNextLine()) {
                        String output = scanner.nextLine();

                        // Filter out unwanted characters and control sequences
                        output = filterOutput(output);

                        // Append each line to the terminal area
                        terminalArea.append(output + "\n");
                        terminalArea.setCaretPosition(terminalArea.getDocument().getLength());

                        // Check if the output contains the sudo password prompt
                        if (output.contains("[sudo] password")) {
                            // Send the password for sudo
                            out.write((password + "\n").getBytes());
                            out.flush();
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }).start();

            // Add an action listener to send commands when the user presses Enter
            commandField.addActionListener(e -> {
                try {
                    String command = commandField.getText() + "\n";
                    out.write(command.getBytes());
                    out.flush();
                    commandField.setText("");
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            });

            // Add a key listener to handle special keys like Tab, Arrow keys, etc.
            commandField.addKeyListener(new java.awt.event.KeyAdapter() {
                public void keyPressed(java.awt.event.KeyEvent evt) {
                    try {
                        int keyCode = evt.getKeyCode();
                        String command = null;

                        switch (keyCode) {
                            case java.awt.event.KeyEvent.VK_TAB:
                                command = "\t";  // Send Tab
                                break;
                            case java.awt.event.KeyEvent.VK_UP:
                                command = "\033[A";  // Send Up Arrow
                                break;
                            case java.awt.event.KeyEvent.VK_DOWN:
                                command = "\033[B";  // Send Down Arrow
                                break;
                            case java.awt.event.KeyEvent.VK_LEFT:
                                command = "\033[D";  // Send Left Arrow
                                break;
                            case java.awt.event.KeyEvent.VK_RIGHT:
                                command = "\033[C";  // Send Right Arrow
                                break;
                            case java.awt.event.KeyEvent.VK_BACK_SPACE:
                                command = "\b";  // Send Backspace
                                break;
                            default:
                                break;
                        }

                        if (command != null) {
                            out.write(command.getBytes());
                            out.flush();
                            evt.consume();  // Prevent further processing of this event
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Method to filter out unwanted control characters and sequences
    private static String filterOutput(String output) {
        // Remove ANSI escape sequences
        output = output.replaceAll("\\e\\[[\\d;]*[^\\d;]", "");
        output = output.replaceAll("\\]\\d+;", "");  // Handle ]0; sequences

        // Remove other common non-printable control characters
        output = output.replaceAll("[\\u0000-\\u001F\\u007F]+", "");

        return output;
    }
}
