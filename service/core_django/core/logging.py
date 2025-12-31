import logging
from pythonjsonlogger import jsonlogger
from datetime import datetime
import time

class TraceIDFilter(logging.Filter):
    def filter(self, record):
        from .middleware import get_current_trace_id
        trace_id = get_current_trace_id()
        if trace_id:
            record.trace_id = trace_id
        return True

class UnifiedJSONFormatter(jsonlogger.JsonFormatter):
    def add_fields(self, log_record, record, message_dict):
        super().add_fields(log_record, record, message_dict)
        
        # Standardize fields
        if not log_record.get('timestamp'):
            log_record['timestamp'] = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S.%fZ')
        
        if log_record.get('level'):
            log_record['level'] = log_record['level'].upper()
        else:
            log_record['level'] = record.levelname
            
        log_record['service'] = 'django-api'
        
        # Ensure msg key
        if log_record.get('message'):
            log_record['msg'] = log_record.pop('message')

