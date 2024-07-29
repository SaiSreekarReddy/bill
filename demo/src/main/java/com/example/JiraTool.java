package com.example;


import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class JiraTool {

    private static final String JIRA_URL = "https://track.td.com";
    private static final String DEFAULT_COMMENT = "The file is uploaded";
    private static final String[] STATUS_OPTIONS = {"In Progress", "Done", "Reopen"};

    private static String username;
    private static String password;
    private static JFrame loginFrame;
    private static JFrame mainFrame;
    private static JTextArea logArea;
    private static JProgressBar progressBar;

    public static void main(String[] args) {
        SwingUtilities.invokeLater(JiraTool::createLoginWindow);
    }

    private static void createLoginWindow() {
        loginFrame = new JFrame("Jira Tool - Login");
        loginFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        loginFrame.setSize(400, 250);
        loginFrame.setLayout(new BorderLayout());

        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBorder(new EmptyBorder(10, 10, 10, 10));

        GridBagConstraints c = new GridBagConstraints();
        c.fill = GridBagConstraints.HORIZONTAL;
        c.insets = new Insets(10, 10, 10, 10);

        JTextField userField = new JTextField();
        JPasswordField passField = new JPasswordField();

        c.gridx = 0;
        c.gridy = 0;
        panel.add(new JLabel("Jira Username:"), c);
        c.gridx = 1;
        panel.add(userField, c);

        c.gridx = 0;
        c.gridy = 1;
        panel.add(new JLabel("Jira Password:"), c);
        c.gridx = 1;
        panel.add(passField, c);

        JButton loginButton = new JButton("Login");
        loginButton.setBackground(new Color(70, 130, 180));
        loginButton.setForeground(Color.WHITE);
        loginButton.setFocusPainted(false);
        c.gridx = 1;
        c.gridy = 2;
        panel.add(loginButton, c);

        loginFrame.add(panel, BorderLayout.CENTER);
        loginFrame.setVisible(true);

        loginButton.addActionListener(e -> {
            username = userField.getText();
            password = new String(passField.getPassword());
            loginFrame.dispose();
            createMainWindow();
        });
    }

    private static void createMainWindow() {
        mainFrame = new JFrame("Jira Tool");
        mainFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        mainFrame.setSize(600, 500);
        mainFrame.setLayout(new BorderLayout());

        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBorder(new EmptyBorder(10, 10, 10, 10));

        GridBagConstraints c = new GridBagConstraints();
        c.fill = GridBagConstraints.BOTH;
        c.insets = new Insets(10, 10, 10, 10);

        JTextField ticketField = new JTextField();
        JTextField commentField = new JTextField();
        JComboBox<String> statusBox = new JComboBox<>(STATUS_OPTIONS);
        logArea = new JTextArea(10, 40);
        logArea.setEditable(false);
        JScrollPane logScrollPane = new JScrollPane(logArea);
        progressBar = new JProgressBar();

        c.gridx = 0;
        c.gridy = 0;
        panel.add(new JLabel("Jira Ticket Number or URL:"), c);
        c.gridx = 1;
        panel.add(ticketField, c);

        c.gridx = 0;
        c.gridy = 1;
        panel.add(new JLabel("Jira Comment:"), c);
        c.gridx = 1;
        panel.add(commentField, c);

        c.gridx = 0;
        c.gridy = 2;
        panel.add(new JLabel("Status:"), c);
        c.gridx = 1;
        panel.add(statusBox, c);

        JButton submitButton = new JButton("Submit");
        submitButton.setBackground(new Color(34, 139, 34));
        submitButton.setForeground(Color.WHITE);
        submitButton.setFocusPainted(false);
        c.gridx = 1;
        c.gridy = 3;
        panel.add(submitButton, c);

        JButton backButton = new JButton("Back");
        backButton.setBackground(new Color(178, 34, 34));
        backButton.setForeground(Color.WHITE);
        backButton.setFocusPainted(false);
        c.gridx = 0;
        panel.add(backButton, c);

        c.gridx = 0;
        c.gridy = 4;
        c.gridwidth = 2;
        panel.add(progressBar, c);

        c.gridx = 0;
        c.gridy = 5;
        c.gridwidth = 2;
        panel.add(logScrollPane, c);

        mainFrame.add(panel, BorderLayout.CENTER);
        mainFrame.setVisible(true);

        backButton.addActionListener(e -> {
            mainFrame.dispose();
            createLoginWindow();
        });

        submitButton.addActionListener(e -> {
            String ticketInput = ticketField.getText();
            final String[] jiraComment = {commentField.getText()};
            if (jiraComment[0].isEmpty()) {
                jiraComment[0] = DEFAULT_COMMENT;
            }
            String desiredStatus = (String) statusBox.getSelectedItem();

            String ticketNumber = extractTicketNumber(ticketInput);
            if (ticketNumber == null) {
                JOptionPane.showMessageDialog(mainFrame, "Invalid ticket number or URL", "Error", JOptionPane.ERROR_MESSAGE);
                return;
            }

            new Thread(() -> {
                try {
                    progressBar.setIndeterminate(true);
                    transitionJiraTicket(ticketNumber, desiredStatus);
                    addCommentToIssue(ticketNumber, jiraComment[0]);
                    log("Transition to " + desiredStatus + " and comment added for ticket " + ticketNumber);
                    JOptionPane.showMessageDialog(mainFrame, "Transition to " + desiredStatus + " and comment added for ticket " + ticketNumber);
                } catch (IOException ex) {
                    log("Error processing request: " + ex.getMessage());
                    JOptionPane.showMessageDialog(mainFrame, "Error processing request: " + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
                } finally {
                    progressBar.setIndeterminate(false);
                }
            }).start();
        });
    }

    private static String extractTicketNumber(String ticketInput) {
        if (ticketInput.contains("/browse/")) {
            String[] parts = ticketInput.split("/browse/");
            return parts.length > 1 ? parts[1] : null;
        }
        return ticketInput;
    }

    private static void transitionJiraTicket(String ticketNumber, String desiredStatus) throws IOException {
        String[] transitionIds = getTransitionIds(ticketNumber);
        if (transitionIds == null) {
            throw new IOException("Invalid ticket number pattern.");
        }

        if (desiredStatus.equals("In Progress")) {
            performTransitions(ticketNumber, transitionIds, 0, 4);
        } else if (desiredStatus.equals("Done")) {
            performTransitions(ticketNumber, transitionIds, 0, 5);
        } else if (desiredStatus.equals("Reopen")) {
            performTransitions(ticketNumber, transitionIds, 0, 0);
        }
    }

    private static String[] getTransitionIds(String ticketNumber) {
        if (ticketNumber.startsWith("CEM")) {
            return new String[]{"11", "701", "681", "691", "711", "51"};
        } else if (ticketNumber.startsWith("CRPHUCC")) {
            return new String[]{"1081", "701", "681", "691", "711", "411"};
        } else {
            return new String[]{"1081", "701", "681", "691", "711", "411"};
        }
    }

    private static void performTransitions(String ticketNumber, String[] transitionIds, int start, int end) throws IOException {
        for (int i = start; i <= end; i++) {
            String transitionId = transitionIds[i];
            String apiUrl = JIRA_URL + "/rest/api/2/issue/" + ticketNumber + "/transitions";
            sendCurlRequest(apiUrl, "{\"transition\": {\"id\": \"" + transitionId + "\"}}");
            log("Performed transition with ID: " + transitionId);
        }
    }

    private static void addCommentToIssue(String ticketNumber, String comment) throws IOException {
        String apiUrl = JIRA_URL + "/rest/api/2/issue/" + ticketNumber + "/comment";
        sendCurlRequest(apiUrl, "{\"body\": \"" + comment + "\"}");
        log("Added comment to ticket: " + ticketNumber);
    }

    private static void sendCurlRequest(String apiUrl, String jsonInputString) throws IOException {
        String encodedCredentials = Base64.getEncoder().encodeToString((username + ":" + password).getBytes(StandardCharsets.UTF_8));
        ProcessBuilder processBuilder = new ProcessBuilder(
            "curl", "-u", username + ":" + password,
            "-X", "POST",
            "-H", "Content-Type: application/json",
            "-d", jsonInputString,
            apiUrl
        );

        Process process = processBuilder.start();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                log(line);
            }
        }
    }

    private static void log(String message) {
        SwingUtilities.invokeLater(() -> logArea.append(message + "\n"));
    }
}
