import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.Scanner;

public class SSHViaCmdWithFiltering {

    public static void main(String[] args) {
        String plinkPath = "C:\\path\\to\\plink.exe"; // Replace with your actual plink.exe path
        String host = "your_vm_ip";
        String user = "your_username";
        String password = "your_password";

        try {
            // Command to open a new command prompt and run plink with SSH
            String[] command = {"cmd.exe", "/c", "start", "cmd.exe", "/K", plinkPath + " -ssh " + user + "@" + host + " -pw " + password};

            ProcessBuilder processBuilder = new ProcessBuilder(command);
            Process process = processBuilder.start();

            // Set up streams for communication with the process
            OutputStream outputStream = process.getOutputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            BufferedReader errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()));

            // Reading and filtering output from the process
            String line;
            while ((line = reader.readLine()) != null || (line = errorReader.readLine()) != null) {
                String filteredLine = filterOutput(line);
                System.out.println(filteredLine);
            }

            // Keeping the session alive for further commands
            Scanner scanner = new Scanner(System.in);
            while (true) {
                System.out.print("Enter command: ");
                String commandInput = scanner.nextLine();
                if ("exit".equals(commandInput)) break;

                outputStream.write((commandInput + "\n").getBytes());
                outputStream.flush();

                // Reading and displaying output from the process
                while ((line = reader.readLine()) != null) {
                    String filteredLine = filterOutput(line);
                    System.out.println(filteredLine);
                }
            }

            // Clean up
            process.destroy();
            reader.close();
            errorReader.close();
            outputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // Method to filter out non-printable characters and escape sequences
    private static String filterOutput(String input) {
        // Remove non-printable characters and escape sequences
        return input.replaceAll("\\p{Cntrl}", "").replaceAll("\\[\\d*\\w", "").replace("]0", "").trim();
    }
}
