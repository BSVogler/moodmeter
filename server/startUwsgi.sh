uwsgi --http :9090 --plugins-dir ~/.local/uwsgi/plugins/python --plugin python34 --manage-script-name --wsgi-file ./moodREST.py
