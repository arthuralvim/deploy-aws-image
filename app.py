import os

from flask import Flask
from flask_restful import Resource, Api

app = Flask(__name__)
api = Api(app)


class EnvironmentVariablesEndpoint(Resource):
    def get(self):
        return [(key, os.environ[key]) for key in os.environ.keys()]


api.add_resource(EnvironmentVariablesEndpoint, '/')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)
