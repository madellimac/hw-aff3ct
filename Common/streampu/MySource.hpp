#ifndef MYSOURCE_H
#define MYSOURCE_H

#include "streampu.hpp"

namespace spu
{
namespace module
{

class MySource  : public Stateful {

private:
    
    int frame_size;
    int max_val;

public:

    MySource(int frame_size, int max_val);
    virtual ~MySource();

protected:

    virtual void generate(int *output, const int frame_id);

};
}
}

#endif // MYSOURCE_H