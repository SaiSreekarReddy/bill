import java.io.IOException;

public class OpenCmdForSSH {

    public static void main(String[] args) {
        String plinkPath = "C:\\path\\to\\plink.exe"; // Replace with your actual plink.exe path
        String host = "your_vm_ip";
        String user = "your_username";
        String password = "your_password";

        try {
            // Command to open a new command prompt and run plink with SSH
            String command = String.format("cmd /c start cmd.exe /K \"%s -ssh %s@%s -pw %s\"", plinkPath, user, host, password);

            // Execute the command to open the new command prompt window
            Runtime.getRuntime().exec(command);

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
