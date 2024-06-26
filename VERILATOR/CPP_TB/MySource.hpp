#ifndef MYSOURCE_H
#define MYSOURCE_H

#include "streampu.hpp"

namespace spu
{
namespace module
{

class MySource  : public Module {

private:
    
    int frame_size;

public:

    MySource(int frame_size);
    virtual ~MySource();

protected:

    virtual void generate(int *output, const int frame_id);

};
}
}

#endif // MYSOURCE_H