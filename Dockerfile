FROM python:3.6.0
COPY . /app
WORKDIR /app
RUN pip install pipenv
RUN pipenv install --system
ENTRYPOINT ["python"]
CMD ["app.py"]
