module.exports = {
  apps : [{
        "name": "wayshub-frontend",
        "cwd" : "/home/adi/docker/wayshub-fronten",
        "script": "npm",
        "args": "start",
        "watch": "false",
        "env": {
                "NODE_ENV": "Deployment"
                }
 }]
};
