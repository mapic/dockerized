module.exports = endpoint = {

    data : {
        delete : '/v2/data/delete',
        layers : '/v2/data/layers',
        update : '/v2/data/update',
        share : '/v2/data/share',
        download : '/v2/data/download',
        vectorize : '/v2/tiles/vectorize',
        import : '/v2/data/import',
        status : '/v2/data/import/status',
        getStatus : '/v2/data/status'
    },

    projects : {
    	data : '/v2/projects/data',
        create : '/v2/projects/create',
        update : '/v2/projects/update',
        delete : '/v2/projects/delete',
        public : '/v2/projects/public',
        private : '/v2/projects/private',
        getLayers : '/v2/projects/layers',
        setAccess : '/v2/projects/access',
        slug : {
            unique : '/v2/projects/slug/unique'
        }
    },

    layers : {
    	delete : '/v2/layers/delete',
    	create : '/v2/layers/create',
    	update : '/v2/layers/update',
    	meta : '/v2/layers/meta',
    	carto : '/v2/layers/carto/json',
        updateCube : '/v2/layers/update/cube',
    },

    tiles : {
        create : '/v2/tiles/create',
        get : '/v2/tiles/',
    },

    users : {
        token : {
            check : '/v2/users/token/check',
            refresh : '/v2/users/token/refresh',
            token : '/v2/users/token'
        },
        update : '/v2/users/update',
        email : {
            unique : '/v2/users/email/unique'
        },
        username : {
            unique : '/v2/users/username/unique'
        },
        invite : {
            invite : '/v2/users/invite',
            projects : '/v2/users/invite/projects',
            link : '/v2/users/invite/link',
            accept : '/v2/users/invite/accept'
        },
        contacts : {
            request : '/v2/users/contacts/request'
        },
        password : {
            reset : '/v2/users/password/reset',
            set : '/v2/users/password'
        },
        create : '/v2/users/create',
        delete : '/v2/users/delete'       
    },

    hashes : {
        get : '/v2/hashes',
        set : '/v2/hashes'
    },

    portal : '/v2/portal',

    status : '/v2/status',


    static: {
        screen : '/v2/static/screen'
    },

    cube : {
        create  : '/v2/cubes/create',
        get     : '/v2/cubes/get', // GET
        add     : '/v2/cubes/add',
        remove  : '/v2/cubes/remove',
        update  : '/v2/cubes/update',
        request : '/v2/cubes/', // GET
        mask    : '/v2/cubes/mask',
        unmask  : '/v2/cubes/unmask',
        replace : '/v2/cubes/replace',
        query   : '/v2/cubes/query',
    }

};