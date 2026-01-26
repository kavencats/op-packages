'use strict';
'require rpc';
'require uci';
'require ui';

var auditRPC = {
    getStatus: rpc.declare({
        object: 'audit',
        method: 'get_status',
        expect: { result: {} }
    }),
    
    getLogs: rpc.declare({
        object: 'audit',
        method: 'get_logs',
        params: ['lines'],
        expect: { data: '' }
    }),
    
    clearLogs: rpc.declare({
        object: 'audit',
        method: 'clear_logs',
        expect: { success: false }
    })
};

return L.Class.extend({
    __init__: function() {
        this.initializeDashboard();
    },
    
    initializeDashboard: function() {
        if (document.getElementById('audit-dashboard')) {
            this.startLiveUpdates();
        }
    },
    
    startLiveUpdates: function() {
        setInterval(function() {
            auditRPC.getStatus().then(function(status) {
                this.updateStatusDisplay(status);
            }.bind(this));
        }.bind(this), 5000);
    },
    
    updateStatusDisplay: function(status) {
        // Update status indicators
        var elements = {
            'status-indicator': status.running ? _('Running') : _('Stopped'),
            'nftables-status': status.nftables ? _('Active') : _('Inactive'),
            'log-size': (status.log_size / 1024).toFixed(2) + ' KB',
            'last-event': status.last_event
        };
        
        for (var id in elements) {
            var element = document.getElementById(id);
            if (element) {
                element.textContent = elements[id];
                if (id.includes('status')) {
                    element.className = elements[id].includes('Running') || elements[id].includes('Active') ? 
                                       'cbi-value-green' : 'cbi-value-red';
                }
            }
        }
    }
});