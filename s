import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.InputStreamReader;

public class JiraStatusChangerUI {

    // Jira base URL and credentials
    private static final String JIRA_BASE_URL = "https://track.td.com";
    private static final String JIRA_USERNAME = "your_jira_username";
    private static final String JIRA_PASSWORD = "your_jira_password";  // Use password here

    // Epic links based on ticket patterns
    private static final String EPIC_LINK_1 = "EPIC-001";  // For pattern abcddrf
    private static final String EPIC_LINK_2 = "EPIC-002";  // For pattern abcdgrp

    public static void main(String[] args) {
        // Create JFrame for UI
        JFrame frame = new JFrame("Jira Status Changer");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(400, 200);

        // Create panel
        JPanel panel = new JPanel();
        frame.add(panel);
        placeComponents(panel);

        // Display the frame
        frame.setVisible(true);
    }

    private static void placeComponents(JPanel panel) {
        panel.setLayout(null);

        // Label for Jira issue key
        JLabel issueLabel = new JLabel("Jira Issue Key:");
        issueLabel.setBounds(10, 20, 150, 25);
        panel.add(issueLabel);

        // Text field for Jira issue key input
        JTextField issueText = new JTextField(20);
        issueText.setBounds(150, 20, 200, 25);
        panel.add(issueText);

        // Button to submit and change the status
        JButton submitButton = new JButton("Change Status and Add Epic Link");
        submitButton.setBounds(150, 100, 250, 25);
        panel.add(submitButton);

        // Action listener for the button click
        submitButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String issueKey = issueText.getText();
                try {
                    // Get current issue status
                    String currentStatus = getIssueStatus(issueKey);
                    JOptionPane.showMessageDialog(panel, "Current status of " + issueKey + ": " + currentStatus);

                    // Perform transitions based on current status
                    handleStatusTransitions(issueKey, currentStatus, panel);

                    // Set the Epic Link based on ticket pattern
                    setEpicLink(issueKey);
                    JOptionPane.showMessageDialog(panel, "Epic Link added to " + issueKey);

                } catch (Exception ex) {
                    JOptionPane.showMessageDialog(panel, "Error: " + ex.getMessage());
                    ex.printStackTrace();
                }
            }
        });
    }

    // Function to handle status transitions based on current status
    private static void handleStatusTransitions(String issueKey, String currentStatus, JPanel panel) throws Exception {
        switch (currentStatus.toLowerCase()) {
            case "to do":
                transitionIssueStatus(issueKey, "Refining");
                transitionIssueStatus(issueKey, "Waiting on Dependencies");
                transitionIssueStatus(issueKey, "Ready to Start");
                transitionIssueStatus(issueKey, "In Progress");
                JOptionPane.showMessageDialog(panel, "Status transitioned to In Progress");
                break;

            case "refining":
                transitionIssueStatus(issueKey, "Waiting on Dependencies");
                transitionIssueStatus(issueKey, "Ready to Start");
                transitionIssueStatus(issueKey, "In Progress");
                JOptionPane.showMessageDialog(panel, "Status transitioned to In Progress");
                break;

            case "waiting on dependencies":
                transitionIssueStatus(issueKey, "Ready to Start");
                transitionIssueStatus(issueKey, "In Progress");
                JOptionPane.showMessageDialog(panel, "Status transitioned to In Progress");
                break;

            case "ready to start":
                transitionIssueStatus(issueKey, "In Progress");
                JOptionPane.showMessageDialog(panel, "Status transitioned to In Progress");
                break;

            case "in progress":
                JOptionPane.showMessageDialog(panel, "Issue is already in In Progress.");
                break;

            default:
                JOptionPane.showMessageDialog(panel, "Unexpected status: " + currentStatus);
        }
    }

    // Function to get the issue's current status using curl
    private static String getIssueStatus(String issueKey) throws Exception {
        String command = String.format(
                "curl -u %s:%s -X GET -H \"Accept: application/json\" \"%s/rest/api/2/issue/%s\"",
                JIRA_USERNAME, JIRA_PASSWORD, JIRA_BASE_URL, issueKey
        );

        // Execute the curl command
        Process process = Runtime.getRuntime().exec(command);
        BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
        StringBuilder result = new StringBuilder();
        String line;

        while ((line = reader.readLine()) != null) {
            result.append(line);
        }

        process.waitFor();

        // Parse the status from the JSON response (simple string search for "status")
        String jsonResponse = result.toString();
        int statusStartIndex = jsonResponse.indexOf("\"status\":") + 10;
        int statusEndIndex = jsonResponse.indexOf("\"", statusStartIndex);
        String currentStatus = jsonResponse.substring(statusStartIndex, statusEndIndex);

        return currentStatus;
    }

    // Function to transition the issue status using curl
    private static boolean transitionIssueStatus(String issueKey, String targetStatus) throws Exception {
        // Get the transition ID for the target status (this would require another curl call, simplified here)
        String transitionId = getTransitionId(targetStatus);
        if (transitionId == null) {
            System.out.println("No valid transition found for target status: " + targetStatus);
            return false;
        }

        // Build the curl command to perform the transition
        String command = String.format(
                "curl -u %s:%s -X POST -H \"Content-Type: application/json\" -d '{\"transition\": {\"id\": \"%s\"}}' \"%s/rest/api/2/issue/%s/transitions\"",
                JIRA_USERNAME, JIRA_PASSWORD, transitionId, JIRA_BASE_URL, issueKey
        );

        // Execute the curl command
        Process process = Runtime.getRuntime().exec(command);
        process.waitFor();

        // If successful, curl should return an empty response body and a status code 204 (No Content)
        return process.exitValue() == 0;
    }

    // Function to get the transition ID for the target status
    private static String getTransitionId(String targetStatus) {
        switch (targetStatus.toLowerCase()) {
            case "in progress":
                return "711";  // Transition ID for In Progress
            case "ready to start":
                return "691";  // Transition ID for Ready to Start
            case "waiting on dependencies":
                return "681";  // Transition ID for Waiting on Dependencies
            case "refining":
                return "701";  // Transition ID for Refining
            default:
                return null;
        }
    }

    // Function to set the Epic Link based on the issue key pattern
    private static void setEpicLink(String issueKey) throws Exception {
        String epicLink = null;

        // Check the first seven letters to determine the Epic Link
        if (issueKey.toLowerCase().startsWith("abcddrf")) {
            epicLink = EPIC_LINK_1;
        } else if (issueKey.toLowerCase().startsWith("abcdgrp")) {
            epicLink = EPIC_LINK_2;
        }

        if (epicLink != null) {
            // Curl command to update the Epic Link of the issue
            String command = String.format(
                    "curl -u %s:%s -X PUT -H \"Content-Type: application/json\" -d '{\"fields\": {\"customfield_10008\": \"%s\"}}' \"%s/rest/api/2/issue/%s\"",
                    JIRA_USERNAME, JIRA_PASSWORD, epicLink, JIRA_BASE_URL, issueKey
            );

            // Execute the curl command
            Process process = Runtime.getRuntime().exec(command);
            process.waitFor();

            if (process.exitValue() != 0) {
                throw new RuntimeException("Failed to update Epic Link for " + issueKey);
            }
        }
    }
}
