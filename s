import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.Scanner;

public class SSHViaCmd {

    public static void main(String[] args) {
        String plinkPath = "C:\\path\\to\\plink.exe"; // Replace with your actual plink.exe path
        String host = "your_vm_ip";
        String user = "your_username";
        String password = "your_password";

        try {
            // Initial command to SSH into the VM
            String[] command = {plinkPath, "-ssh", user + "@" + host, "-pw", password};

            ProcessBuilder processBuilder = new ProcessBuilder(command);
            Process process = processBuilder.start();

            // Set up streams for communication with the process
            OutputStream outputStream = process.getOutputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            BufferedReader errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()));

            // Executing `sudo su`
            outputStream.write("sudo su\n".getBytes());
            outputStream.flush();

            // Sending the password for sudo
            outputStream.write((password + "\n").getBytes());
            outputStream.flush();

            // Reading and displaying output from the process
            String line;
            while ((line = reader.readLine()) != null || (line = errorReader.readLine()) != null) {
                System.out.println(line);
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
                    System.out.println(line);
                }
            }

            // Clean up
            process.destroy();
            reader.close();
            errorReader.close();
            outputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
