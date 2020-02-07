


python -m apache_beam.examples.wordcount \
    --input gs://dataflow-samples/shakespeare/kinglear.txt \
    --runner DataflowRunner \
    --project your-gcp-project-id \
    --temp_location gs://<your-gcs-bucket>/tmp/