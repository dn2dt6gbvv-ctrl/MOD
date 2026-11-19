                                                   
#if defined _vectoral_included
    #endinput
#endif
#define _vectoral_included

#define CV_MAX_VECTORS  32
#define CV_MAX_SIZE     512

static cv_data[CV_MAX_VECTORS][CV_MAX_SIZE];
static cv_size[CV_MAX_VECTORS];
static cv_count = 0;

stock cvector()
{
    if(cv_count >= CV_MAX_VECTORS) return -1;
    cv_size[cv_count] = 0;
    cv_count++;
    return cv_count - 1;
}

stock cvector_push_back(vecid, value)
{
    if(vecid < 0 || vecid >= cv_count) return 0;
    if(cv_size[vecid] >= CV_MAX_SIZE) return 0;
    cv_data[vecid][cv_size[vecid]] = value;
    cv_size[vecid]++;
    return 1;
}

stock cvector_size(vecid)
{
    if(vecid < 0 || vecid >= cv_count) return 0;
    return cv_size[vecid];
}

stock cvector_get(vecid, index)
{
    if(vecid < 0 || vecid >= cv_count) return 0;
    if(index < 0 || index >= cv_size[vecid]) return 0;
    return cv_data[vecid][index];
}

stock cvector_find(vecid, value)
{
    if(vecid < 0 || vecid >= cv_count) return -1;
    for(new i = 0; i < cv_size[vecid]; i++)
        if(cv_data[vecid][i] == value) return i;
    return -1;
}

stock cvector_remove(vecid, index)
{
    if(vecid < 0 || vecid >= cv_count) return 0;
    if(index < 0 || index >= cv_size[vecid]) return 0;
    for(new i = index; i < cv_size[vecid] - 1; i++)
        cv_data[vecid][i] = cv_data[vecid][i+1];
    cv_size[vecid]--;
    return 1;
}
