# Use the official Python image as the base image
FROM python:3.9

# Set the working directory
WORKDIR /app

# Copy the required files and folders
COPY application /app/application
COPY entrypoint.sh .

# Install dependencies
RUN pip install --no-cache-dir -r application/requirements.txt

# Expose the port the app runs on
EXPOSE 5000

# Start the application
COPY init.sql /docker-entrypoint-initdb.d/init.sql
ENTRYPOINT [ "./entrypoint.sh" ]

CMD ["python", "application/app.py"]
#COPY init.sql /docker-entrypoint-initdb.d/init.sql