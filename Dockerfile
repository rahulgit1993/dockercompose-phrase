# Use the official Python image as the base image
FROM python:3.9

# Set the working directory
WORKDIR /app

# Copy the requirements.txt file
#COPY requirements.txt app.py create_db.py drop_db.py entrypoint.sh
COPY application /app/application
COPY entrypoint.sh .
#RUN ls -l /app
# Install dependencies
#:WORKDIR /app
RUN pip install --no-cache-dir -r application/requirements.txt

# Copy the rest of the application code
#COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Start the application
# ENTRYPOINT ["python"]
# CMD ["sleep", "1200s"]
COPY init.sql /docker-entrypoint-initdb.d/init.sql
ENTRYPOINT [ "./entrypoint.sh" ]

CMD ["python", "application/app.py"]
#COPY init.sql /docker-entrypoint-initdb.d/init.sql
