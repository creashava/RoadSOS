# Deployment Guide: RoadSOS

This guide explains how to quickly push your codebase to GitHub and deploy the application (Frontend to Vercel, Backend logic to Render or Supabase).

---

### Step 1: Push Code to GitHub

First, save your project online using Git.

1. Open a new terminal in your VScode for this project.
2. Stop any running servers (press `Ctrl + C`).
3. Run these commands:
   ```bash
   git init
   git add .
   git commit -m "Initial commit for RoadSOS project"
   ```
4. Go to [GitHub (github.com)](https://github.com/new) and create a **New Repository**.
   * Give it a name like `roadsos-pwa`.
   * Keep it Public or Private.
   * **Do NOT check "Initialize with README"** (leave it empty).
5. Copy the second set of instructions GitHub gives you (under "push an existing repository") and run them in your terminal. It will look like this:
   ```bash
   git remote add origin https://github.com/YourUsername/YourRepoName.git
   git branch -M main
   git push -u origin main
   ```

---

### Step 2: Deploy Frontend on Vercel

Vercel is the best platform to host Vite React applications like RoadSOS.

1. Create a free account at [Vercel](https://vercel.com/signup).
2. Click **Add New Project**.
3. Connect your GitHub account and Import the repository you just created in Step 1.
4. Vercel will automatically detect that you're using **Vite**.
   * Check **Build Command**: `npm run build` or `vite build`
   * Check **Output Directory**: `dist`
5. Open the **Environment Variables** section before deploying and add:
   * `VITE_SUPABASE_URL` = **Your Supabase URL**
   * `VITE_SUPABASE_ANON_KEY` = **Your Supabase Anon Key**
6. Click **Deploy**. Vercel will build the project and give you a live public URL (e.g. `https://roadsos.vercel.app`).

---

### Step 3: Deploy Backend APIs on Render 

*(Note: The React app uses Supabase for database management, so you only need Render if you have a separate Python/Node FastAPI for ML features like the incident severity ML model.)*

1. Commit your backend code to a separate GitHub repo or a separate folder.
2. Create a free account at [Render.com](https://render.com/).
3. Click **New +** and select **Web Service**.
4. Connect to your Backend GitHub repository.
5. Setup the configurations:
   * **Environment**: e.g., `Python 3`
   * **Build Command**: `pip install -r requirements.txt`
   * **Start Command**: `uvicorn main:app --host 0.0.0.0 --port 10000`
6. Click **Create Web Service**. 
7. Once deployed, Render will give you an API URL. Go back to your Vercel Environment Variables in Settings, add `VITE_ML_API_URL` with this Render link, and redeploy your Vercel app.

---

🎉 **You're all done! Your RoadSOS application is fully live.**
