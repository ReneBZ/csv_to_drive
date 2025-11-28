# CSV to Google Sheets Auto-Uploader

This tool allows you to double-click a `.csv` file in macOS Finder (via Automator) to automatically upload it to Google Drive, convert it to a Google Sheet, and open it in your browser.

## Prerequisites

1.  **Python 3**: Ensure Python 3 is installed.
2.  **Google Cloud Project**: You need a Google Cloud Project with the Drive API enabled.

## Setup

### 1. Install Dependencies

Open a terminal and navigate to this folder:

```bash
cd /path/to/csv_to_drive
pip3 install -r requirements.txt
```

### 2. Configure Google Credentials

1.  Go to the [Google Cloud Console](https://console.cloud.google.com/).
2.  Create a new project or select an existing one.
3.  Enable the **Google Drive API**.
4.  Go to **Credentials** -> **Create Credentials** -> **OAuth client ID**.
5.  Select **Desktop app**.
6.  Download the JSON file and rename it to `credentials.json`.
7.  Place `credentials.json` in this folder (`/Users/renebravo/Python/csv_to_drive`).

### 3. First Run (Authentication)

Run the script manually once to authenticate and generate the `token.pickle` file:

```bash
python3 csv_to_sheets.py /path/to/test.csv
```

A browser window will open asking for permission. Allow access.

### 4. Create macOS Automator Application

1.  Open **Automator** on your Mac.
2.  Select **New Document** -> **Application**.
3.  Search for **Run Shell Script** and drag it to the workflow area.
4.  In the "Pass input" dropdown, select **as arguments**.
5.  Paste the following command (update the path to your `launcher.sh`):

    ```bash
    /Users/renebravo/Python/csv_to_drive/launcher.sh "$@"
    ```

    *Note: Ensure `launcher.sh` is executable (`chmod +x launcher.sh`).*

6.  Save the Automator app (e.g., "CSV to Sheets").

### 5. Usage

1.  Right-click a `.csv` file in Finder.
2.  Select **Open With** -> **CSV to Sheets** (or whatever you named your Automator app).
3.  Alternatively, drag and drop `.csv` files onto the Automator app icon.

The file will be uploaded, converted, and opened in your default browser.


## Alternative: "Quick Action" (Recommended for Downloaded Files)

If you frequently download CSVs from the web (e.g., AWS, Bank statements), macOS might block the "Open With" method with a "malware" warning. The best workaround is to create a **Quick Action** instead of an Application.

1.  Open **Automator**.
2.  Select **New Document** -> **Quick Action**.
3.  Configure the top settings:
    *   Workflow receives current: **files or folders**
    *   in: **Finder**
    *   Image: **Spreadsheet** (optional)
4.  Add the **"Run Shell Script"** action.
    *   Pass input: **as arguments**
    *   Command: `/Users/renebravo/Python/csv_to_drive/launcher.sh "$@"`
5.  Save it as **"Upload to Sheets"**.

**Usage:**
Right-click any CSV file -> **Quick Actions** -> **Upload to Sheets**.
This usually bypasses the security warning without needing to modify file attributes.


